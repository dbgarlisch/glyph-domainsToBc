# glyph-domainsToBc API

It is possible to source this script in your own Glyph scripts and use it as a library.

To source this script add the following lines to your script:

```Tcl
    set disableAutoRun_DomainsToBc 1 ;# disable the autorun
    source "/some/path/to/your/copy/of/DomainsToBc.glf"
```

See the script `test/test01.glf` for an example.

### Table of Contents
* [Namespace pw::DomainsToBc](#namespace-pwthicken2d)
* [pw::DomainsToBc Library Docs](#pwthicken2d-library-docs)
* [pw::DomainsToBc Library Usage Examples](#pwthicken2d-library-usage-examples)
    * [Thickening a 2D Grid for the COBALT Solver](#thickening-a-2d-grid-for-the-cobalt-solver)
* [Disclaimer](#disclaimer)


## Namespace pw::DomainsToBc

All of the procs in this collection reside in the **pw::DomainsToBc** namespace.

To call a proc in this collection, you must prefix the proc name with a **pw::DomainsToBc::** namespace specifier.

For example:
```Tcl
set disableAutoRun_DomainsToBc 1 ;# disable the autorun
source "/some/path/to/your/copy/of/DomainsToBc.glf"
pw::DomainsToBc::setVerbose 1
pw::DomainsToBc::createAndApply $doms
```

To avoid the long namespace prefix, you can also import the public **pw::DomainsToBc** procs into your script.

For example:
```Tcl
set disableAutoRun_DomainsToBc 1 ;# disable the autorun
source "/some/path/to/your/copy/of/DomainsToBc.glf"
# import all public procs
namespace import ::pw::DomainsToBc::*
setVerbose 1
createAndApply $doms
```

```Tcl
set disableAutoRun_DomainsToBc 1 ;# disable the autorun
source "/some/path/to/your/copy/of/DomainsToBc.glf"
# import specific public procs
namespace import ::pw::DomainsToBc::setVerbose
namespace import ::pw::DomainsToBc::createAndApply
setVerbose 1
createAndApply $doms
```


## pw::DomainsToBc Library Docs

```Tcl
pw::DomainsToBc::setVerbose { val }
```
Sets the level of runtime trace information dumped by the script.
<dl>
  <dt><code>val</code></dt>
  <dd>If set to 1, full trace information is dumped. If set to 0, only minimal trace information is dumped. (default: 0)</dd>
</dl>
<br/>

```Tcl
pw::DomainsToBc::setFirstGUID { val }
```
Sets the starting GUID value.
<dl>
  <dt><code>val</code></dt>
  <dd>The starting GUID used for the %GUID% macro expansion. The GUID is incremented each time it is used.</dd>
</dl>
<br/>

```Tcl
pw::DomainsToBc::setDefaultEntNameId { val }
```
Sets the value to use for the %EntNameId% macro when the entity name does not end with "-nn".
<dl>
  <dt><code>val</code></dt>
  <dd>Value used when the %EntNameId% macro does not have a value.</dd>
</dl>
<br/>

```Tcl
pw::DomainsToBc::setOverwrite { val }
```
Controls how to deal with entities that already have a BC applied.
<dl>
  <dt><code>val</code></dt>
  <dd>Set to 1 to allow overwriting of existing entity BCs. Set to 0 to skip all entities that already have a BC applied.</dd>
</dl>
<br/>

```Tcl
pw::DomainsToBc::setDefaultPattern { val }
```
Sets the default naming parameter.
<dl>
  <dt><code>val</code></dt>
  <dd>The default name pattern. This pattern is used if a specific pattern is not assigned to a given usage. Macro expansion is performed on this pattern to determine a new BC's name.</dd>
</dl>
<br/>

```Tcl
pw::DomainsToBc::setSplitCnxnBc { val }
```
Controls how BCs are applied to connection entities.
<dl>
  <dt><code>val</code></dt>
  <dd>Set to 1 to apply distinct BCs to all sides of a connection. Set to 0 to share the same BC on all sides of a connection.</dd>
</dl>
<br/>

```Tcl
pw::DomainsToBc::setBcPhysicalType { usage val }
```
Sets the physical type used for BCs applied to entities with the given usage.
<dl>
  <dt><code>usage</code></dt>
  <dd>The usage type. One of free, boundary, or connection</dd>
  <dt><code>val</code></dt>
  <dd>The solver specific BC physical type name. If a physical type value is set to an empty string ("") for a given usage type, BCs are not applied those entities.</dd>
</dl>
<br/>

```Tcl
pw::DomainsToBc::setBcPattern { usage val }
```
Sets the naming pattern used for BCs applied to entities with the given usage.
<dl>
  <dt><code>usage</code></dt>
  <dd>The usage type. One of free, boundary, or connection</dd>
  <dt><code>val</code></dt>
  <dd>The naming pattern. If a pattern is not defined for a non-ignored usage, $defPattern is used unless splitCnxnBc is 1. In that case, "$defPattern:%VolName%" is used.</dd>
</dl>
<br/>

```Tcl
pw::DomainsToBc::createAndApply { ents }
```
Thickens a 2D grid into an extruded 3D grid.
<dl>
  <dt><code>domsToThicken</code></dt>
  <dd>A list of 2D blocks (domains) to thicken.</dd>
</dl>

## pw::DomainsToBc Library Usage Examples

### Create a unique BC for Each Domain

```Tcl
    set disableAutoRun_DomainsToBc 1 ;# disable the autorun
    source "/some/path/to/your/copy/of/DomainsToBc.glf"

    # Set to 0/1 to disable/enable TRACE messages
    pw::DomainsToBc::setVerbose 1

    # GUID values will start at 100
    pw::DomainsToBc::setFirstGUID 100

    # Used for xx when a domain name does not end in "-nn" id.
    pw::DomainsToBc::setDefaultEntNameId "X"

    # Force all domains to get new BCs
    pw::DomainsToBc::setOverwrite 1

    # Set default NC naming pattern
    pw::DomainsToBc::setDefaultPattern "bc_%EntNameBase%-%GUID%"

    # Do not use same BC on both sides of a connection
    pw::DomainsToBc::setSplitCnxnBc 1

    # Do NOT apply BCs to free entities
    pw::DomainsToBc::setBcPhysicalType free ""

    # Set the BC physical type used for free entities
    pw::DomainsToBc::setBcPhysicalType boundary "Wall"

    # Set the BC physical type used for free entities
    pw::DomainsToBc::setBcPhysicalType connection "Pressure Drop"

    # Set the BC naming pattern used for connection entities
    pw::DomainsToBc::setBcPattern connection "bc_%EntNameBase%:%VolNameBase%-%GUID%"

    pw::DomainsToBc::createAndApply [pw::Grid getAll -type pw::Domain]
```


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
