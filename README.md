# glyph-domainsToBc

This glyph script

![domainsToBc Banner Image](../master/images/banner.png  "domainsToBc banner Image")


### Table of Contents
* [Running The Script](#running-the-script)
    * [Dialog Box Options](#dialog-box-options)
* [Script Limitations](#script-limitations)
* [Sourcing This Script](#sourcing-this-script)
* [Disclaimer](#disclaimer)


## Running The Script

* Build a 3D grid. The CAE dimension **must** be set to 3.
* Execute this script.
* Set the desired options in the dialog box.
* Press OK to apply a unique BC to every domain.

### Dialog Box Options

* **Name Pattern** - xxxx.
* **BC Physical Type** - xxxx.
* **First GUID** - xxxx.
* **Default Name Id** - xxxx.
* **Overwrite Existing BCs** - xxxx.
* **Split Connection BCs** - xxxx.
* **Enable verbose output** - Select this option to see detailed runtime information. Unselect this option to see minimal runtime information.


## Script Limitations

Only 3D grids are supported.


## Sourcing This Script

It is possible to source this script in your own Glyph scripts and use it as a
library.

See the [Domains To BC API Docs](docs/DomainsToBc_API.md) for information on how
to use this script as a library.


## Disclaimer
Scripts are freely provided. They are not supported products of
Pointwise, Inc. Some scripts have been written and contributed by third
parties outside of Pointwise's control.

TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, POINTWISE DISCLAIMS
ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, WITH REGARD TO THESE SCRIPTS. TO THE MAXIMUM EXTENT PERMITTED
BY APPLICABLE LAW, IN NO EVENT SHALL POINTWISE BE LIABLE TO ANY PARTY
FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES
WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS
INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE USE OF OR
INABILITY TO USE THESE SCRIPTS EVEN IF POINTWISE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF THE FAULT OR NEGLIGENCE OF
POINTWISE.
