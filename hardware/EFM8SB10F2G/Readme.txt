NVIDIA Jetson Power Button Supervisor Firmware

Build environment of the attached binary file (EFM8SB10F2G.hex):
Simplicity Studio 4 with 8051 SDK v4.1.1 on Windows 10

How to setup and build the binary from the source code:
1. Download Simplicity Studio for your OS:
   https://www.silabs.com/products/development-tools/software/simplicity-studio
2. Install and start Simplicity Studio.
3. If "Installation Manager" is not prompted, go to Help > Update Software.
   In "Installation Manager", select "Install by Device".
   Enter and select "EFM8SB10F2G" in "Product Search".
   Press ">>" button to move "EFM8SB10F2G" to the "Selected devices" list.
   Press "Next" and follow the steps to install all the required SDK and tools.
4. File > Import > More Import Options... > General > Existing Projects
   into Workspace
5. Select "Select root directory" option and Click "Browse..." to select the
   source folder.
6. The project name "EFM8SB10F2G" will show up in the "Projects:" list. Check
   the project and click "Finish".
7. In "Simplicity IDE" window (choose from the top right corner if you are not
   there), you can build the binary by clicking the hammer icon in the Toolbar
   or right click on the project name > Build Project in Project Explorer.
8. After the building process is done, locate the binary file "EFM8SB10F2G.hex"
   in the Debug folder.

Installation of 8051 SDK version 4.1.1:
1. Go to Help > Update Software.
2. In "Product Manager", make sure there's nothing needed to install
   in "Product Updates" tab. Otherwise, step (4) will be blocked.
3. In "SDKs" tab, select Categories - "8051" and Version - "All"
4. Locate "8051 SDK - 4.1.1" and click "Install".

To build with 8051 SDK version 4.1.1:
1. In "Simplicity IDE" window (choose from the top right corner if you are not
   there), right click on the project name > "Properties".
2. In the list on the left side, select "C/C++ Build" > "Board / Part / SDK".
   Select v4.1.1 in the dropdown list in "SDK:".
3. Click "Apply" and "OK" to exit.
4. Right click on the project name > "Clean project" and rebuild.

Changelog:
- Version 0.11
  * Optimization: Reduce FORCE_SHUTDOWN_N reaction time.
- Version 0.10
  * Initial release.