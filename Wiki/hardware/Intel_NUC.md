# NUC11ATKC4
## Update BIOS

Find the updated BIOS from here:
<https://www.intel.com/content/www/us/en/download/721452/bios-update-atjslcpx.html>
Choose an "OS Independent" `.cap` BIOS file, and download it onto a USB drive.

BTW, more downloads are available for the Intel NUC at:
<https://www.intel.com/content/www/us/en/products/sku/217669/intel-nuc-11-essential-kit-nuc11atkc4/downloads.html>

Now, follow this procedure:

   - shut down the Intel NUC completely (not in hibernate or sleep mode)
   - plug the USB drive into a USB port of the Intel NUC
   - turn on the Intel NUC

   - during boot, when the F7 prompt is displayed, press F7 to enter the BIOS
     Flash Update screen

   - select the USB device and press Enter
   - select the `.cap` file and press Enter
   - confirm you want to update the BIOS by pressing Enter
   - wait 2-5 minutes for the update to complete
   - remove the USB flash drive
   - restart the Intel NUC

For more info: <https://downloadmirror.intel.com/781955/NUC-AptioV-UEFI-Firmware-BIOS-Update-Readme.pdf>
