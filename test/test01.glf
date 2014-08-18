#
# Copyright 2014 (c) Pointwise, Inc.
# All rights reserved.
#
# This sample script is not supported by Pointwise, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#


# ===============================================
# THICKEN 2D GRID TEST SCRIPT
# ===============================================
# Using DomainsToBc.glf as a library

package require PWI_Glyph 2.17

set disableAutoRun_DomainsToBc 1
source [file join [file dirname [info script]] "../DomainsToBc.glf"]

pw::Application reset -keep Clipboard
set mode [pw::Application begin ProjectLoader]
$mode initialize [file join [file dirname [info script]] "test-3D.pw"]
$mode setAppendMode false
$mode load
$mode end
unset mode

# Set to 0/1 to disable/enable TRACE messages
pw::DomainsToBc::setVerbose 1

pw::DomainsToBc::createAndApply [pw::Grid getAll -type pw::Domain]

# END SCRIPT

#
# DISCLAIMER:
# TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, POINTWISE DISCLAIMS
# ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
# TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE, WITH REGARD TO THIS SCRIPT.  TO THE MAXIMUM EXTENT PERMITTED
# BY APPLICABLE LAW, IN NO EVENT SHALL POINTWISE BE LIABLE TO ANY PARTY
# FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES
# WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF
# BUSINESS INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE
# USE OF OR INABILITY TO USE THIS SCRIPT EVEN IF POINTWISE HAS BEEN
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF THE
# FAULT OR NEGLIGENCE OF POINTWISE.
#
