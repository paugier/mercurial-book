  $ cp $TESTS_ROOT/data/remove-redundant-null-checks.patch .

#$ name: tools
  $ diffstat -p1 remove-redundant-null-checks.patch
   drivers/char/agp/sgi-agp.c        |    5 ++---
   drivers/char/hvcs.c               |   11 +++++------
   drivers/message/fusion/mptfc.c    |    6 ++----
   drivers/message/fusion/mptsas.c   |    3 +--
   drivers/net/fs_enet/fs_enet-mii.c |    3 +--
   drivers/net/wireless/ipw2200.c    |   22 ++++++----------------
   drivers/scsi/libata-scsi.c        |    4 +---
   drivers/video/au1100fb.c          |    3 +--
   8 files changed, 19 insertions(+), 38 deletions(-)

  $ filterdiff -i '*/video/*' remove-redundant-null-checks.patch
  --- a/drivers/video/au1100fb.c~remove-redundant-null-checks-before-free-in-drivers
  +++ a/drivers/video/au1100fb.c
  @@ -743,8 +743,7 @@ void __exit au1100fb_cleanup(void)
   {
   	driver_unregister(&au1100fb_driver);
   
  -	if (drv_info.opt_mode)
  -		kfree(drv_info.opt_mode);
  +	kfree(drv_info.opt_mode);
   }
   
   module_init(au1100fb_init);

#$ name: lsdiff
  $ lsdiff -nvv remove-redundant-null-checks.patch
  22	File #1  	a/drivers/char/agp/sgi-agp.c
  	24	Hunk #1	static int __devinit agp_sgi_init(void)
  37	File #2  	a/drivers/char/hvcs.c
  	39	Hunk #1	static struct tty_operations hvcs_ops = 
  	53	Hunk #2	static int hvcs_alloc_index_list(int n)
  69	File #3  	a/drivers/message/fusion/mptfc.c
  	71	Hunk #1	mptfc_GetFcDevPage0(MPT_ADAPTER *ioc, in
  85	File #4  	a/drivers/message/fusion/mptsas.c
  	87	Hunk #1	mptsas_probe_hba_phys(MPT_ADAPTER *ioc)
  98	File #5  	a/drivers/net/fs_enet/fs_enet-mii.c
  	100	Hunk #1	static struct fs_enet_mii_bus *create_bu
  111	File #6  	a/drivers/net/wireless/ipw2200.c
  	113	Hunk #1	static struct ipw_fw_error *ipw_alloc_er
  	126	Hunk #2	static ssize_t clear_error(struct device
  	140	Hunk #3	static void ipw_irq_tasklet(struct ipw_p
  	150	Hunk #4	static void ipw_pci_remove(struct pci_de
  164	File #7  	a/drivers/scsi/libata-scsi.c
  	166	Hunk #1	int ata_cmd_ioctl(struct scsi_device *sc
  178	File #8  	a/drivers/video/au1100fb.c
  	180	Hunk #1	void __exit au1100fb_cleanup(void)
