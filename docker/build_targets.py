import argparse
import yaml
import pprint
import urllib.request
import os
import time
import sys
import zipfile
import tarfile
import subprocess


def parse_yaml(filename):
    try:
        targets = yaml.load(open(filename),Loader=yaml.Loader)
    except Exception as e:
        print("Error: Can't parse YAML file %s" % filename)
        print(e)
        exit(-1)
    return targets


def reporthook(count, block_size, total_size):
    global start_time
    if count == 0:
        start_time = time.time()
        return
    # duration = time.time() - start_time
    # progress_size = int(count * block_size)
    # # speed = int(progress_size / (1024 * duration))
    # percent = int(count * block_size * 100 / total_size)
    # sys.stdout.write("\r...%d%%, %d MB, %d KB/s, %d seconds passed" %
    #                 (percent, progress_size / (1024 * 1024), speed, duration))
    # sys.stdout.flush()
    # return


def download_and_extract(asset):
    """
    Attempts to download asset passed as dict argument.
    'path' and 'url' must exist.
    """
    try:
        print('Trying to download from: ' + asset['url'])
        path = os.path.dirname(asset['path'])
        basename = os.path.basename(asset['url'])
        download_path = path+'/'+basename
        if not os.path.exists(path):
            os.makedirs(path)
        urllib.request.urlretrieve(asset['url'], download_path, reporthook)
        print(" Done.\n")
        if asset['path'] != basename:
            extract_archive(path+'/'+basename)
            print("Done.\n")
    except Exception as e:
        print("Download Failed. Check your YAML file.")
        print("Exiting now...\n")
        print(e)
        exit(-1)
    return


def extract_archive(filename):
    print("Extracting: "+filename)
    path = os.path.dirname(filename)
    if tarfile.is_tarfile(filename):
        print("File is tarball. Extracting now...")
        with tarfile.TarFile(filename) as tf:
            tf.extractall(path)
        # Extract tarball
    elif zipfile.is_zipfile(filename):
        print("File is zipfile. Extracting now...")
        with zipfile.ZipFile(filename) as zf:
            zf.extractall(path)
    else:
        print("Archive format is not supported.")

    return


def validate_assets(assets):
    """
    Validates if an asset exsits. If it doesn't exist a download will be attempted.
    Process is interrupted on the first failed validation.
    """

    for a, d in assets.items():
        print('Validating: ' + a)
        if not os.path.exists(d['path']):
            print("Couldn't find " + d['path'])
            print("Atempting download now...")
            download_and_extract(d)
        else:
            print("Done.\n")
    return


def build_target(target, cmd):
    command = build_cmd(target, cmd)
    print(command)
    process = subprocess.Popen(command)
    process.wait()
    print("\n\n\n\n\n")
    return


def build_cmd(target, cmd):
    params = []
    params += [cmd['cmd']]
    for param in cmd['params']:
        p = '--' + param + '='
        if param in target.keys():
            p += target[param]
        elif param in target['Assets']:
            p += target['Assets'][param]['path']
        else:
            print("Couldn't find param: "+param)

        print(param+': '+p)
        params += [p]
    if target['SkipUpdate']:
        params += ['--SkipUpdate=True']
    params += ['--MountDir=mnt']
    return params


def build_targets(filename):
    """
    Build targets as specified in YAML file. This process includes:
    Validate assets:
            - All assets for all targets must exist before build process starts.
            - If a asset doesn't exist, download will be attempted.
            - If downloaded is an archive it will be extracted.
    Build targets:
            - By default, base image will be mounted and updated (from fakeroot)
                    unless update=False is specified.
            - Packages in 'Packages' key will be installed (from fakeroot).
            - Device tree binary files (.dtb) will be copied to target /boot and symlink
                    for 'default_name-->default_dtb' will be created.
            - fstab will be replaced if the asset exists (original moved to /etc/fstab.old)
            - Uboot will be injected, starting in sector 1 if the asset exists.
    """

    # Parse YAML configuration file
    config = parse_yaml(filename)
    print("Building with config:")
    pprint.pprint(config)

    # Validate and download assets for all targets:
    for a, t in config['Targets'].items():
        print('Validating assets for: ' + a)
        validate_assets(t['Assets'])

    # Build targets:
    for a, t in config['Targets'].items():
        print("Building target: " + a)
        build_target(t, config['BuildCommand'])
    return()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument('-t', '--config', help='Path to targets YAML file.')
    args = parser.parse_args()
    filename = args.config

    build_targets(filename)
    exit(0)
