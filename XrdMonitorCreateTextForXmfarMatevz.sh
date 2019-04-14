#!/bin/bash
THESITE=T2_US_Florida
if [ $# -gt 0 ] ; then
   THESITE=$1
fi
echo Site=$THESITE
what=$(basename $0 | cut -d. -f1)
notifytowhom=your.email.eddress@somewhere
#workdir=$HOME/CMS_Site_IO/SitePerform
#[ -d $workdir ] || mkdir -p $workdir
CMSSW_VER="CMSSW_10_4_0_patch1"
KERNEL_NAME="XrdMonitor"
cmssw_dir=cmssw
[ $(echo $CMSSW_VER | grep -q patch ; echo $?) -eq 0 ] && cmssw_dir=cmssw-patch
SCRAM_ARCH=$(ls -d /cvmfs/cms.cern.ch/$(/cvmfs/cms.cern.ch/common/cmsos)*/cms/${cmssw_dir}/${CMSSW_VER} | tail -n 1 | awk -F / '{ print $4 }')
export SCRAM_ARCH
echo INFO SCRAM_ARCH=$SCRAM_ARCH at $(pwd)
source /cvmfs/cms.cern.ch/cmsset_default.sh
cat << EOF > ${what}-jupyter-wrapper.sh
#!/bin/bash
source /cvmfs/cms.cern.ch/cmsset_default.sh
cd /cvmfs/cms.cern.ch/$SCRAM_ARCH/cms/${cmssw_dir}/${CMSSW_VER}
eval \`scramv1 runtime -sh\`
cd - 2>/dev/null 1>/dev/null
exec python "\$@"
EOF
chmod a+x ${what}-jupyter-wrapper.sh
echo INFO created : ${what}-jupyter-wrapper.sh

cat << EOF > ${what}-setup.sh
#!/bin/bash
source /cvmfs/cms.cern.ch/cmsset_default.sh
cd /cvmfs/cms.cern.ch/$SCRAM_ARCH/cms/${cmssw_dir}/${CMSSW_VER}
eval \`scramv1 runtime -sh\`
cd - 2>/dev/null 1>/dev/null
#exec python "\$@"
EOF
echo INFO created : ${what}-setup.sh
myjupytortop=/s/b/b
if [ -d $myjupytortop ] ; then
if [ ! -f $myjupytertop/.local/share/jupyter/kernels/$KERNEL_NAME/kernel.json ] ; then
# Create the kernel
mkdir -p "$myjupytertop/.local/share/jupyter/kernels/$KERNEL_NAME"
cat << EOF > "$myjupytertop/.local/share/jupyter/kernels/$KERNEL_NAME/kernel.json"
{
 "display_name": "$KERNEL_NAME", 
 "language": "python", 
 "argv": [
  "$PWD/${what}-jupyter-wrapper.sh", 
  "-m", 
  "ipykernel_launcher", 
  "-f", 
  "{connection_file}"
 ]
}
EOF
echo INFO created : $myjupytertop/.local/share/jupyter/kernels/$KERNEL_NAME/kernel.json
fi
else
echo Warning Jupyter top directory is unknown. This may be OK.
fi

# Report OK
echo "We are using python "
which python
echo "Loaded $CMSSW_VERSION into $KERNEL_NAME!"
source ${what}-setup.sh
export PYTHONUNBUFFERED=1
python XrdMonitorCreateTextForXmfarMatevz.py | while read siteline ; do read xrddata ; site=$(echo $siteline | awk '{print $NF}') ; [ "x$site" == "x$THESITE" ] || continue ; date=$(date -d@$(echo $xrddata | awk '{print $1}') -u +%Y-%m-%d"T"%H:%M:%S"Z"); echo $date $xrddata Site=$site 2>&1 | tee -a XrdMonitorCreateTextForXmfarMatevz.txt ; done

exit 0
