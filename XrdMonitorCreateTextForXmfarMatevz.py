import os
import sys
import ROOT

#os.environ['X509_CERT_DIR'] = '/cvmfs/grid.cern.ch/etc/grid-security/certificates'
#os.environ['X509_VOMS_DIR'] = '/cvmfs/grid.cern.ch/etc/grid-security/vomsdir'
os.environ['X509_CERT_DIR'] = '/cvmfs/cms.cern.ch/grid/etc/grid-security/certificates'
os.environ['X509_VOMS_DIR'] = '/cvmfs/cms.cern.ch/grid/etc/grid-security/vomsdir'
    
root_file="root://cms-xrd-global.cern.ch//store/user/nvanegas/BckgndW+Jets/tag_1_delphes_events01.root"
root_file="root://gftp-1.t2.ucsd.edu:1094//store/user/matevz/xmfar-2019-04-partial.root"
root_file="xmfar-2019-04-partial.root"
if "root://" in root_file:
   #os.environ['X509_USER_PROXY'] = 'your_grid_proxy_file_pull_path'
   if os.path.isfile(os.environ['X509_USER_PROXY']):
    pass
   else:
    print "os.environ['X509_USER_PROXY'] ",os.environ['X509_USER_PROXY']
    print "You need to put your grid proxy somewhere, e.g., /eos/user/<your alpha>/<Username>"
    sys.exit(1)

tfile = ROOT.TFile.Open(root_file)

#print "Listing Tree"
#tfile.ls()

tree = tfile.Get("XrdFar")

#tree.Print()
#tree.Show(1)

entries=tree.GetEntriesFast()
#print "Entries = ", entries
for i in xrange(entries):
    tree.GetEntry(i)
    leaves=str(tree.GetLeaf("F.mCloseTime").GetValue(i))
    for l in tree.GetListOfLeaves():
        if "S.mSite" in l.GetName() : continue
        leaves=leaves+" "+l.GetName()+"="+str(tree.GetLeaf(l.GetName()).GetValue(i))
    tree.GetLeaf("S.mSite").PrintValue(i)
    print leaves
    
