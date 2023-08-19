gcloud compute instances create rvcinstance-1 \
--project=eminent-sunrise-396420 \
--zone=us-central1-a \
--machine-type=a2-ultragpu-1g \
--network-interface=network-tier=PREMIUM,nic-type=GVNIC,stack-type=IPV4_ONLY,subnet=default \
--metadata=startup-script='#!/bin/bash
set -e

# Update package lists for upgrades and new package installations
sudo apt-get update

# Check and install git if not present
if ! command -v git &> /dev/null
then
    sudo apt-get install -y git
fi

# Check and install curl if not present
if ! command -v curl &> /dev/null
then
    sudo apt-get install -y curl
fi

# Check and install python3 if not present
if ! command -v python3 &> /dev/null
then
    sudo apt-get install -y python3
fi

# Rest of your startup script...

# Create virtual environment
echo "Creating virtual environment"
python3 -m venv rvc || { echo "Could not create virtual environment. Exiting script."; exit 1; }

# Activate the virtual environment
echo "Activating virtual environment"
source rvc/bin/activate

echo "Updating package lists"
sudo apt-get update

echo "Installing git-lfs"
sudo apt-get install git-lfs

echo "Cloning GitHub repository"
git clone https://github.com/an-internet-user001/RVC.git Retrieval-based-Voice-Conversion-WebUI

echo "Navigating to the directory"
cd Retrieval-based-Voice-Conversion-WebUI || { echo "Could not navigate to directory. Exiting script."; exit 1; }

echo "Cloning Hugging Face repository"
git clone https://huggingface.co/lj1995/VoiceConversionWebUI.git tempdir
rsync -av --exclude-from="excluded_files.txt" tempdir/ .

echo "Removing temporary directory"
rm -rf tempdir

echo "Installing dependencies"
pip install torch torchvision torchaudio || { echo "Could not install packages with pip. Exiting script."; exit 1; }

echo "Installing Poetry"
curl -sSL https://install.python-poetry.org | python3 - || { echo "Could not install Poetry. Exiting script."; exit 1; }

echo "Using Poetry to install further dependencies"
poetry install || { echo "Could not install packages with Poetry. Exiting script."; exit 1; }

echo "Installing dependencies from requirements.txt"
pip install -r requirements.txt || { echo "Could not install packages from requirements.txt. Exiting script."; exit 1; }

echo "Launching the application"
python infer-web.py
' \
--can-ip-forward \
--maintenance-policy=TERMINATE \
--provisioning-model=STANDARD \
--service-account=31420661161-compute@developer.gserviceaccount.com \
--scopes=https://www.googleapis.com/auth/cloud-platform \
--accelerator=count=1,type=nvidia-a100-80gb \
--tags=http-server,https-server \
--create-disk=auto-delete=yes,boot=yes,device-name=primarydrive,image=projects/ml-images/global/images/c0-deeplearning-common-cu113-v20230807-debian-10,mode=rw,size=500,type=projects/eminent-sunrise-396420/zones/us-central1-a/diskTypes/pd-balanced \
--create-disk=device-name=dataset,mode=rw,name=dataset,size=500,type=projects/eminent-sunrise-396420/zones/us-central1-a/diskTypes/pd-ssd \
--shielded-secure-boot \
--shielded-vtpm \
--shielded-integrity-monitoring \
--labels=goog-ec-src=vm_add-gcloud \
--reservation-affinity=any \
--threads-per-core=2 \
--visible-core-count=6
