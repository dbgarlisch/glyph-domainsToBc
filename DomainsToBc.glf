#
# Copyright 2014 (c) Pointwise, Inc.
# All rights reserved.
#
# This sample script is not supported by Pointwise, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#


# ===============================================
# DOMAINS TO BC SCRIPT - POINTWISE
# ===============================================
# https://github.com/pointwise/DomainsToBc
#
# Vnn: Release Date / Author
# v01: Aug 16, 2014 / David Garlisch
#
# ===============================================

if { ![namespace exists pw::DomainsToBc] } {

package require PWI_Glyph


#####################################################################
#                       public namespace procs
#####################################################################
namespace eval pw::DomainsToBc {
  namespace export setVerbose
  namespace export setFirstGUID
  namespace export setDefaultEntNameId
  namespace export setOverwrite
  namespace export setSplitCnxnBc
  namespace export setDefaultPattern
  namespace export setBcPhysicalType
  namespace export setBcPattern
  namespace export createAndApply
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::setVerbose { val } {
  setOpt verbose $val
  traceMsg "Setting verbose = [getOpt verbose]."
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::setFirstGUID { val } {
  setOpt firstGUID $val
  traceMsg "Setting firstGUID = [getOpt firstGUID]."
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::setDefaultEntNameId { val } {
  setOpt defEntNameId "$val"
  traceMsg "Setting defEntNameId = [getOpt defEntNameId]."
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::setOverwrite { val } {
  setOpt overwrite $val
  traceMsg "Setting overwrite = [getOpt overwrite]."
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::setDefaultPattern { val } {
  setOpt defPattern "$val"
  traceMsg "Setting defPattern = [getOpt defPattern]."
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::setSplitCnxnBc { val } {
  setOpt splitCnxnBc $val
  traceMsg "Setting splitCnxnBc = [getOpt splitCnxnBc]."
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::setBcPhysicalType { usage val } {
  variable opts
  dict set opts usage $usage physType "$val"
  traceMsg "Setting $usage physType = [dict get $opts usage $usage physType]."
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::setBcPattern { usage val } {
  variable opts
  dict set opts usage $usage pattern "$val"
  traceMsg "Setting $usage pattern = [dict get $opts usage $usage pattern]."
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::createAndApply { ents } {
  init
  dumpOptions
  if { 3 == [pw::Application getCAESolverDimension] } {
    traceMsg "Applying BCs to domains..."
    pw::DomainsToBc::createAndApply3D [pw::DomainsToBc::filter Domain $ents]
  } else {
    traceMsg "Applying BCs to connectors..."
    pw::DomainsToBc::createAndApply2D [pw::DomainsToBc::filter Connector $ents]
  }
}


#####################################################################
#               private namespace procs and variables
#####################################################################
namespace eval pw::DomainsToBc {

  # Configuration options.
  #
  #   verbose - Set to 1 to enable verbose runtime output
  #   firstGUID - The starting GUID used for the %GUID% macro expansion
  #   defEntNameId - Value used when the %EntNameId% does not have a value.
  #   overwrite - Set to 1 to allow overwriting of existing entity BCs. Set to 0
  #               to skip all entities that already have a BC applied.
  #   defPattern - The default name pattern. This pattern is used if a specific
  #                pattern is not assigned to a given usage. Macro expansion is
  #                performed on this pattern to determine a new BC's name.
  #   splitCnxnBc - Set to 1 to apply distinct BCs to all sides of a connection.
  #                 Set to 0 to share the same BC on all sides of a connection.
  #
  # Boundary usage options:
  #
  #   The BC entity usage is one of free, boundary, or connection. Each entity
  #   usage has its own set of options.
  #
  #   physType - The BC physical type to use for BCs.If a physical type value is
  #              not defined for a given usage type, those entities are ignored.
  #   pattern - The naming pattern to use for BCs. If a pattern is not defined
  #             for a non-ignored usage, $defPattern is used unless splitCnxnBc
  #             is 1. In that case, "$defPattern:%VolName%" is used.
  #
  # Pattern expansion macros:
  #   These macros are supported by all usage types:
  #
  #   %EntName% - The boundary entity name as returned by [$ent getName]. The
  #               boundary entity is a domain in 3D and a connector in 2D.
  #   %EntNameBase% - The boundary entity name with the -nn suffix removed.
  #   %EntNameId% - The nn portion of the boundary entity name. If none,
  #                 $defEntNameId is used.
  #   %EntType% - The boundary entity type as returned by [$ent getType] with
  #               the "pw::" prefix removed.
  #   %EntType3%" - The first three chars of %EntType%.
  #   %GUID% - A sequentially increasing, globally unique integer value.
  #
  # These macros are only supported by boundary and connection usage types:
  #
  #   %VolName% - The volume entity name as returned by [$ent getName]. The
  #               volume entity is a block in 3D and a domain in 2D.
  #   %VolNameBase% - The volume entity name with the -nn suffix removed.
  #   %VolNameId% - The nn portion of the volume entity name. If none,
  #                 $defEntNameId is used.
  #   %VolType% - The volume entity type as returned by [$ent getType] with the
  #               "pw::" prefix removed.
  #   %VolType3%" - The first three chars of %VolType%.
  #
  variable opts [ \
    dict create \
      verbose       0 \
      firstGUID     1 \
      defEntNameId  X \
      overwrite     0 \
      defPattern    {bc_%EntName%} \
      splitCnxnBc   0 \
      usage { \
	free { \
	  physType {Unspecified} \
	  pattern  {} \
	} \
	boundary { \
	  physType {Unspecified} \
	  pattern  {} \
	} \
	connection { \
	  physType {} \
	  pattern  {} \
	} \
      } \
  ]

  # runtime GUID value. Is reset to firstGUID before each run.
  variable nextGUID 1
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::dumpOptions { } {
  variable opts
  set fmt "  %-20s = '%s'"
  traceMsg "Options:"
  foreach key [dict keys $opts] {
    if { $key == "usage" } {
      continue
    }
    traceMsg [format $fmt $key [dict get $opts $key]]
  }
  foreach usage {free boundary connection} {
    foreach key {physType pattern} {
      traceMsg [format $fmt "$usage.$key" [dict get $opts usage $usage $key]]
    }
  }
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::createAndApply2D { cons } {
  if { 2 != [pw::Application getCAESolverDimension] } {
    fatalMsg "This script requires a 2D grid."
  }
  fatalMsg "2D grids are not supported."
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::createAndApply3D { ents } {
  variable nextGUID

  if { 3 != [pw::Application getCAESolverDimension] } {
    fatalMsg "This script requires a 3D grid."
  }

  dumpInfo $ents

  set nextGUID [getOpt firstGUID]
  foreach ent $ents {
    createAndApplyBcToEnt $ent
  }
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::createAndApplyBcToEnt { ent } {
  variable nextGUID
  set usage [getUsage $ent blks]
  set physType [getOptPhysicalType $usage]
  if { $physType != "" } {
    set pattern [getOptPattern $usage]
    switch $usage {
    free {
      # grab the free domain's default BC
      set bc [pw::BoundaryCondition getByEntities $ent]
      if { [canSetBc $bc] } {
	set bc [pw::BoundaryCondition create]
	$bc setName [evalPattern $pattern [entToMap $ent] cnts]
	$bc setPhysicalType $physType
	traceMsg "Applying BC [$bc getName] to $usage [$ent getName]..."
	$bc apply $ent
	incr nextGUID [dict get $cnts GUID]
      } else {
	traceMsg "Skipping $usage [$ent getName]"
      }
    }
    boundary {
      set blk [lindex $blks 0]
      # entity's usage register
      set reg [list $blk $ent]
      # grab the bndry domain's current register BC
      set bc [pw::BoundaryCondition getByEntities $reg]
      if { [canSetBc $bc] } {
	set bc [pw::BoundaryCondition create]
	$bc setName [evalPattern $pattern [entToMap $ent $blk] cnts]
	$bc setPhysicalType $physType
	traceMsg "Applying BC [$bc getName] to $usage [$ent getName]..."
	$bc apply $reg
	incr nextGUID [dict get $cnts GUID]
      } else {
	traceMsg "Skipping $usage [$ent getName]"
      }
    }
    connection {
      foreach blk $blks {
	set reg [list $blk $ent]
	set bc [pw::BoundaryCondition getByEntities $reg]
	set allOk 1
	if { ![canSetBc $bc] } {
	  set allOk 0
	  break
	}
      }
      if { !$allOk } {
	# one or more regs could not be set to a new BC
	traceMsg "Skipping $usage [$ent getName]"
	break
      }
      # it is rare yet, possible that an ent is used in more than twice!
      set createBc 1 ;# always create new BC on first pass
      foreach blk $blks {
	set reg [list $blk $ent]
	if { $createBc } {
	  set bc [pw::BoundaryCondition create]
	  # Are we sharing or spliting cnxn BCs?
	  set createBc [getOpt splitCnxnBc]
	  $bc setName [evalPattern $pattern [entToMap $ent $blk] cnts]
	  $bc setPhysicalType $physType
	}
	traceMsg "Applying BC [$bc getName] to $usage register [$ent getName]:[$blk getName]..."
	$bc apply $reg
	incr nextGUID [dict get $cnts GUID]
      }
    }}
  } else {
    traceMsg "Skipping $usage [$ent getName]"
  }
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::isUnspecified { bc } {
  return [expr {"[$bc getName]" == "Unspecified"}]
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::canSetBc { bc } {
  return [expr {[isUnspecified $bc] || [getOpt overwrite]}]
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::evalPattern { pattern map matchesVar } {
  if { "" != $matchesVar } {
    upvar $matchesVar matches
  }
  set matches [dict create]
  dict for {key val} $map {
    set cnt [regsub -all "%${key}%" $pattern $val pattern]
    dict set matches $key $cnt
  }
  return $pattern
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::entToMap { ent {vol ""} } {
  variable nextGUID
  set name [$ent getName]
  regexp {^(.+?)(-([0-9]+)|)$} $name -> baseName -> id
  if { "" == $id } {
    set id [getOpt defEntNameId]
  }
  set entType [string range [$ent getType] 4 end]
  set entType3 [string range $entType 0 2]
  set ret [dict create \
	    EntName     $name \
	    EntNameBase $baseName \
	    EntNameId   $id \
	    EntType     $entType \
	    EntType3    $entType3 \
	    GUID        $nextGUID \
	  ]
  set ret [decomposeName $ent "Ent"]
  if { "" != $vol } {
    set ret [dict merge $ret [decomposeName $vol "Vol"]]
  }
  dict set ret GUID $nextGUID
  return $ret
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::decomposeName { ent pfx } {
  set name [$ent getName]
  regexp {^(.+?)(-([0-9]+)|)$} $name -> baseName -> id
  if { "" == $id } {
    set id [getOpt defEntNameId]
  }
  set entType [string range [$ent getType] 4 end]
  set entType3 [string range $entType 0 2]
  return  [dict create \
	    ${pfx}Name     $name \
	    ${pfx}NameBase $baseName \
	    ${pfx}NameId   $id \
	    ${pfx}Type     $entType \
	    ${pfx}Type3    $entType3 \
	  ]
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::dumpInfo { ents } {
  variable nextGUID
  set nextGUID [getOpt firstGUID]
  set fmt "%-15s: %s" ;# attrib value
  foreach ent $ents {
    traceMsg "Domain: '[$ent getName]'"
    traceMsg [format $fmt "defaultBC" [bcToString [pw::BoundaryCondition getByEntities $ent]]]
    set suffix ""
    set usage [getUsage $ent blks]
    if { "free" != $usage } {
      set suffix " for"
      set sep ""
      foreach blk $blks {
	append suffix "$sep '[$blk getName]'"
	set sep " and"
      }
    }
    traceMsg [format $fmt "usage" "${usage}${suffix}"]
    if { "free" != $usage } {
      set regs ""
      set sep ""
      foreach blk $blks {
	set reg [list $blk $ent]
	append regs "$sep[bcToString [pw::BoundaryCondition getByEntities $reg]]"
	set sep " and "
      }
      traceMsg [format $fmt "regsisters" $regs]
    }
    if { [getOptPhysicalType $usage] == "" } {
      set ignored "yes"
    } else {
      set ignored "no"
      traceMsg [format $fmt "physical type" [getOptPhysicalType $usage]]
      set pattern [getOptPattern $usage]
      set map [entToMap $ent]
      set eg [evalPattern $pattern $map cnts]
      traceMsg [format $fmt "pattern" "'$pattern' (e.g. $eg)"]
      incr nextGUID [dict get $cnts GUID]
    }
    traceMsg [format $fmt "ignored" $ignored]
    traceMsg ""
  }
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::getUsage { dom {blksVar ""} } {
  if { "" != $blksVar } {
    upvar $blksVar blks
  }
  set blks [pw::Block getBlocksFromDomains [list $dom]]
  return [
    switch [llength $blks] {
    0 {
      set ret "free"
    }
    1 {
      set ret "boundary"
    }
    default {
      set ret "connection"
    }}
  ]
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::getOpt { key } {
  variable opts
  return [dict get $opts $key]
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::setOpt { key val } {
  variable opts
  dict set opts $key $val
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::getOptPattern { usage } {
  variable opts
  set ret [dict get $opts usage $usage pattern]
  if { $ret == "" } {
    if { ($usage == "connection") && [getOpt splitCnxnBc] } {
      set ret "[getOpt defPattern]:%VolName%"
    } else {
      set ret [getOpt defPattern]
    }
  }
  return $ret
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::getOptPhysicalType { usage } {
  variable opts
  return [dict get $opts usage $usage physType]
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::filter { etype ents } {
  set ret [list]
  set etype "pw::$etype"
  #traceMsg "Filtering entities of type ${etype}..."
  foreach ent $ents {
    if { [$ent isOfType "$etype"] } {
      #traceMsg "  Adding [$ent getName]"
      lappend ret $ent
    } else {
      #traceMsg "  Ignoring [$ent getName]"
    }
  }
  return $ret
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::init {} {
  traceMsg "**** Initializing namespace pw::DomainsToBc ..."
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::fatalMsg { msg {exitCode -1} } {
  puts "  ERROR: $msg"
  exit $exitCode
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::warningMsg { msg {exitCode -1} } {
  puts "  WARNING: $msg"
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::traceMsg { msg } {
  if { [getOpt verbose] } {
    puts "  TRACE: $msg"
  }
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::bcToString { bc } {
  return "\{'[$bc getName]' '[$bc getPhysicalType]' [$bc getId]\}"
}


#####################################################################
#                       private namespace GUI procs
#####################################################################
namespace eval pw::DomainsToBc::gui {

  namespace import ::pw::DomainsToBc::*

  variable errors [dict create]
  variable bcTypes [pw::BoundaryCondition getPhysicalTypes]
  set bcTypes [linsert $bcTypes 0 ""]

  # options
  variable caeSolver      [pw::Application getCAESolver]
  variable isVerbose      0
  variable firstGUID      1
  variable defEntNameId   "X"
  variable overwrite      0
  variable defPattern     {bc_%EntName%}
  variable splitCnxnBc    0
  variable freePhysType   {Unspecified}
  variable freePattern    {}
  variable bndryPhysType  {Unspecified}
  variable bndryPattern   {}
  variable cnxnPhysType   {}
  variable cnxnPattern    {}

  # widget hierarchy
  variable w
  set w(LabelTitle)         .title
  set w(FrameMain)          .main

  set w(DefPatternLabel)    $w(FrameMain).defPatternLabel
  set w(DefPatternEntry)    $w(FrameMain).defPatternEntry

  set w(PhysTypeLabel)      $w(FrameMain).physTypeLabel
  set w(PatternLabel)       $w(FrameMain).patternLabel

  set w(FreePhysTypeLabel)  $w(FrameMain).freePhysTypeLabel
  set w(FreePhysTypeCombo)  $w(FrameMain).freePhysTypeCombo
  set w(FreePatternEntry)   $w(FrameMain).freePatternEntry

  set w(BndryPhysTypeLabel) $w(FrameMain).bndryPhysTypeLabel
  set w(BndryPhysTypeCombo) $w(FrameMain).bndryPhysTypeCombo
  set w(BndryPatternEntry)  $w(FrameMain).bndryPatternEntry

  set w(CnxnPhysTypeLabel)  $w(FrameMain).cnxnPhysTypeLabel
  set w(CnxnPhysTypeCombo)  $w(FrameMain).cnxnPhysTypeCombo
  set w(CnxnPatternEntry)   $w(FrameMain).cnxnPatternEntry

  set w(FirstGuidLabel)     $w(FrameMain).firstGuidLabel
  set w(FirstGuidEntry)     $w(FrameMain).firstGuidEntry

  set w(DefEntNameIdLabel)  $w(FrameMain).defEntNameIdLabel
  set w(DefEntNameIdEntry)  $w(FrameMain).defEntNameIdEntry

  set w(OverwriteCheck)     $w(FrameMain).overwriteCheck
  set w(SplitCnxnBcCheck)   $w(FrameMain).splitCnxnBcCheck
  set w(VerboseCheck)       $w(FrameMain).verboseCheck

  set w(FrameButtons)        .fbuttons
    set w(Logo)              $w(FrameButtons).logo
    set w(OkButton)          $w(FrameButtons).okButton
    set w(CancelButton)      $w(FrameButtons).cancelButton
} ;# namespace eval pw::DomainsToBc::gui


#----------------------------------------------------------------------------
proc pw::DomainsToBc::gui::run { } {
  makeWindow
  tkwait window .
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::gui::checkErrors { } {
  variable errors
  variable w
  if { 0 == [dict size $errors] } {
    set state normal
  } else {
    set state disabled
  }
  if { [catch {$w(OkButton) configure -state $state} err] } {
    #puts $err
  }
  return 1
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::gui::validateInput { val type key } {
  variable errors
  if { [string is $type -strict $val] } {
    dict unset errors $key
  } else {
    dict set errors $key 1
  }
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::gui::validateInteger { val key } {
  validateInput $val integer $key
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::gui::validateDouble { val key } {
  validateInput $val double $key
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::gui::validateString { val key } {
  validateInput $val print $key
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::gui::okAction { } {
  variable caeSolver
  variable isVerbose
  variable firstGUID
  variable defEntNameId
  variable overwrite
  variable defPattern
  variable splitCnxnBc
  variable freePhysType
  variable freePattern
  variable bndryPhysType
  variable bndryPattern
  variable cnxnPhysType
  variable cnxnPattern

  setVerbose $isVerbose
  setFirstGUID $firstGUID
  setDefaultEntNameId $defEntNameId
  setOverwrite $overwrite
  setSplitCnxnBc $splitCnxnBc
  setDefaultPattern $defPattern
  setBcPhysicalType free $freePhysType
  setBcPhysicalType boundary $bndryPhysType
  setBcPhysicalType connection $cnxnPhysType
  setBcPattern free $freePattern
  setBcPattern boundary $bndryPattern
  setBcPattern connection $cnxnPattern

  #pw::Display getSelectedEntities selEnts

  # Capture a list of all the grid's ents
  set allEnts [pw::Grid getAll -type pw::Domain]
  # Only keep the visible and selectable ents
  set entsToApply {}
  foreach ent $allEnts {
    if { ![pw::Display isLayerVisible [$ent getLayer]] } {
      continue
    } elseif { ![$ent getEnabled] } {
      continue
    } else {
      lappend entsToApply $ent
    }
  }
  createAndApply $entsToApply
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::gui::defPatternAction { action newVal oldVal } {
  if { -1 != $action } {
    patternAction default $action $newVal $oldVal
    checkErrors
  }
  return 1
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::gui::physTypeAction { id action newVal oldVal } {
  #puts "physTypeAction '$id' '$action' '$newVal' '$oldVal'"
  variable w
  if { "" == $newVal } {
    $w($id) configure -state disabled
  } else {
    $w($id) configure -state normal
  }
  checkErrors
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::gui::patternAction { id action newVal oldVal } {
  #puts "patternAction '$id' '$action' '$newVal' '$oldVal'"
  variable w
  #if { "" == $newVal } {
  #  $w($id) configure -state disabled
  #} else {
  #  $w($id) configure -state normal
  #}
  checkErrors
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::gui::freePhysTypeAction { action newVal oldVal } {
  physTypeAction FreePatternEntry $action $newVal $oldVal
  return 1
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::gui::freePatternAction { action newVal oldVal } {
  if { -1 != $action } {
    patternAction free $action $newVal $oldVal
    checkErrors
  }
  return 1
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::gui::bndryPhysTypeAction { action newVal oldVal } {
  physTypeAction BndryPatternEntry $action $newVal $oldVal
  return 1
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::gui::bndryPatternAction { action newVal oldVal } {
  if { -1 != $action } {
    patternAction bndry $action $newVal $oldVal
    checkErrors
  }
  return 1
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::gui::cnxnPhysTypeAction { action newVal oldVal } {
  physTypeAction CnxnPatternEntry $action $newVal $oldVal
  return 1
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::gui::cnxnPatternAction { action newVal oldVal } {
  if { -1 != $action } {
    patternAction cnxn $action $newVal $oldVal
    checkErrors
  }
  return 1
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::gui::firstGUIDAction { action newVal oldVal } {
  if { -1 != $action } {
    validateInteger $newVal firstGUID
    checkErrors
  }
  return 1
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::gui::defEntNameIdAction { action newVal oldVal } {
  if { -1 != $action } {
    validateString $newVal DefEntNameId
    checkErrors
  }
  return 1
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::gui::makeWindow { } {
  variable w
  variable caeSolver
  variable bcTypes

  set patternWd  30
  set physTypeWd 25

  set disabledBgColor [ttk::style lookup TEntry -fieldbackground disabled]
  ttk::style map TCombobox -fieldbackground [list disabled $disabledBgColor]

  # create the widgets
  label $w(LabelTitle) -text "Domains to BC ($caeSolver)"
  setTitleFont $w(LabelTitle)

  frame $w(FrameMain) -padx 15

  label $w(PatternLabel)  -text "Name Pattern" -anchor w
  label $w(PhysTypeLabel) -text "BC Physical Type" -anchor w

  label $w(FreePhysTypeLabel) -text "Free Entity" -anchor w
  entry $w(FreePatternEntry) \
    -textvariable pw::DomainsToBc::gui::freePattern \
    -width $patternWd \
    -validate key \
    -validatecommand { pw::DomainsToBc::gui::freePatternAction %d %P %s }
  ttk::combobox $w(FreePhysTypeCombo) \
    -values $bcTypes \
    -state readonly \
    -textvariable pw::DomainsToBc::gui::freePhysType \
    -width $physTypeWd \
    -validate key \
    -validatecommand { pw::DomainsToBc::gui::freePhysTypeAction %d %P %s }
  bind $w(FreePhysTypeCombo) <<ComboboxSelected>> \
    {pw::DomainsToBc::gui::freePhysTypeAction 9 $pw::DomainsToBc::gui::freePhysType \
      $pw::DomainsToBc::gui::freePhysType}

  label $w(BndryPhysTypeLabel) -text "Boundary Entity" -anchor w
  entry $w(BndryPatternEntry) \
    -textvariable pw::DomainsToBc::gui::bndryPattern \
    -width $patternWd \
    -validate key \
    -validatecommand { pw::DomainsToBc::gui::bndryPatternAction %d %P %s }
  ttk::combobox $w(BndryPhysTypeCombo) \
    -values $bcTypes \
    -state readonly \
    -textvariable pw::DomainsToBc::gui::bndryPhysType \
    -width $physTypeWd \
    -validate key \
    -validatecommand { pw::DomainsToBc::gui::bndryPhysTypeAction %d %P %s }
  bind $w(BndryPhysTypeCombo) <<ComboboxSelected>> \
    {pw::DomainsToBc::gui::bndryPhysTypeAction 9 $pw::DomainsToBc::gui::bndryPhysType \
      $pw::DomainsToBc::gui::bndryPhysType}

  label $w(CnxnPhysTypeLabel) -text "Connection Entity" -anchor w
  entry $w(CnxnPatternEntry) \
    -textvariable pw::DomainsToBc::gui::cnxnPattern \
    -width $patternWd \
    -validate key \
    -validatecommand { pw::DomainsToBc::gui::cnxnPatternAction %d %P %s }
  ttk::combobox $w(CnxnPhysTypeCombo) \
    -values $bcTypes \
    -state readonly \
    -textvariable pw::DomainsToBc::gui::cnxnPhysType \
    -width $physTypeWd \
    -validate key \
    -validatecommand { pw::DomainsToBc::gui::cnxnPhysTypeAction %d %P %s }
  bind $w(CnxnPhysTypeCombo) <<ComboboxSelected>> \
    {pw::DomainsToBc::gui::cnxnPhysTypeAction 9 $pw::DomainsToBc::gui::cnxnPhysType \
      $pw::DomainsToBc::gui::cnxnPhysType}

  label $w(DefPatternLabel) -text "Default" -anchor w
  entry $w(DefPatternEntry) \
    -textvariable pw::DomainsToBc::gui::defPattern \
    -width $patternWd \
    -validate key \
    -validatecommand { pw::DomainsToBc::gui::defPatternAction %d %P %s }

  label $w(FirstGuidLabel) -text "First GUID" -anchor w
  entry $w(FirstGuidEntry) \
    -textvariable pw::DomainsToBc::gui::firstGUID \
    -width 10 \
    -validate key \
    -validatecommand { pw::DomainsToBc::gui::firstGUIDAction %d %P %s }

  label $w(DefEntNameIdLabel) -text "Default Name Id" -anchor w
  entry $w(DefEntNameIdEntry) \
    -textvariable pw::DomainsToBc::gui::defEntNameId \
    -width 10 \
    -validate key \
    -validatecommand { pw::DomainsToBc::gui::defEntNameIdAction %d %P %s }

  checkbutton $w(OverwriteCheck) -text "Overwrite Exisiting BCs" \
    -variable pw::DomainsToBc::gui::overwrite -anchor w -padx 20 -state active

  checkbutton $w(SplitCnxnBcCheck) -text "Split Connection BCs" \
    -variable pw::DomainsToBc::gui::splitCnxnBc -anchor w -padx 20 -state active

  checkbutton $w(VerboseCheck) -text "Enable verbose output" \
    -variable pw::DomainsToBc::gui::isVerbose -anchor w -padx 20 -state active

  frame $w(FrameButtons) -relief sunken -padx 15 -pady 5

  label $w(Logo) -image [pwLogo] -bd 0 -relief flat
  button $w(OkButton) -text "OK" -width 12 -bd 2 \
    -command { wm withdraw . ; pw::DomainsToBc::gui::okAction ; exit }
  button $w(CancelButton) -text "Cancel" -width 12 -bd 2 \
    -command { exit }

  # lay out the form
  pack $w(LabelTitle) -side top -pady 5
  pack [frame .sp -bd 2 -height 2 -relief sunken] -pady 0 -side top -fill x
  pack $w(FrameMain) -side top -fill both -expand 1 -pady 10

  # lay out the form in a grid
  set row 0
  grid $w(PatternLabel)       -row $row -column 1 -sticky w -pady 3 -padx 3
  grid $w(PhysTypeLabel)      -row $row -column 2 -sticky w -pady 3 -padx 3

  incr row
  grid $w(FreePhysTypeLabel)    -row $row -column 0 -sticky we -pady 3 -padx 3
  grid $w(FreePatternEntry)     -row $row -column 1 -sticky w -pady 3 -padx 3
  grid $w(FreePhysTypeCombo)    -row $row -column 2 -sticky w -pady 3 -padx 3

  incr row
  grid $w(BndryPhysTypeLabel)    -row $row -column 0 -sticky we -pady 3 -padx 3
  grid $w(BndryPatternEntry)     -row $row -column 1 -sticky w -pady 3 -padx 3
  grid $w(BndryPhysTypeCombo)    -row $row -column 2 -sticky w -pady 3 -padx 3

  incr row
  grid $w(CnxnPhysTypeLabel)    -row $row -column 0 -sticky we -pady 3 -padx 3
  grid $w(CnxnPatternEntry)     -row $row -column 1 -sticky w -pady 3 -padx 3
  grid $w(CnxnPhysTypeCombo)    -row $row -column 2 -sticky w -pady 3 -padx 3

  incr row
  grid $w(DefPatternLabel)    -row $row -column 0 -sticky we -pady 3 -padx 3
  grid $w(DefPatternEntry)    -row $row -column 1 -sticky w -pady 3 -padx 3

  incr row
  grid $w(FirstGuidLabel)       -row $row -column 0 -sticky we -pady 3 -padx 3
  grid $w(FirstGuidEntry)       -row $row -column 1 -sticky w -pady 3 -padx 3

  incr row
  grid $w(DefEntNameIdLabel)    -row $row -column 0 -sticky we -pady 3 -padx 3
  grid $w(DefEntNameIdEntry)    -row $row -column 1 -sticky w -pady 3 -padx 3

  incr row
  grid $w(OverwriteCheck)       -row $row -columnspan 2 -sticky we -pady 3 -padx 3

  incr row
  grid $w(SplitCnxnBcCheck)     -row $row -columnspan 2 -sticky we -pady 3 -padx 3

  incr row
  grid $w(VerboseCheck)         -row $row -columnspan 2 -sticky we -pady 3 -padx 3

  # lay out buttons
  pack $w(CancelButton) $w(OkButton) -pady 3 -padx 3 -side right
  pack $w(Logo) -side left -padx 5

  # give extra space to (only) column
  grid columnconfigure $w(FrameMain) 1 -weight 1

  pack $w(FrameButtons) -fill x -side bottom -padx 0 -pady 0 -anchor s

  variable freePhysType
  variable bndryPhysType
  variable cnxnPhysType

  # init GUI state for BC data
  freePhysTypeAction 8 $freePhysType $freePhysType
  bndryPhysTypeAction 8 $bndryPhysType $bndryPhysType
  cnxnPhysTypeAction 8 $cnxnPhysType $cnxnPhysType

  focus $w(VerboseCheck)
  raise .

  # don't allow window to resize
  wm resizable . 0 0
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::gui::setTitleFont { widget {fontScale 1.5} } {
  # set the font for the input widget to be bold and 1.5 times larger than
  # the default font
  variable titleFont
  if { ! [info exists titleFont] } {
    set fontSize [font actual TkCaptionFont -size]
    set titleFont [font create -family [font actual TkCaptionFont -family] \
      -weight bold -size [expr {int($fontScale * $fontSize)}]]
  }
  $widget configure -font $titleFont
}


#----------------------------------------------------------------------------
proc pw::DomainsToBc::gui::pwLogo {} {
  set logoData "
R0lGODlheAAYAIcAAAAAAAICAgUFBQkJCQwMDBERERUVFRkZGRwcHCEhISYmJisrKy0tLTIyMjQ0
NDk5OT09PUFBQUVFRUpKSk1NTVFRUVRUVFpaWlxcXGBgYGVlZWlpaW1tbXFxcXR0dHp6en5+fgBi
qQNkqQVkqQdnrApmpgpnqgpprA5prBFrrRNtrhZvsBhwrxdxsBlxsSJ2syJ3tCR2siZ5tSh6tix8
ti5+uTF+ujCAuDODvjaDvDuGujiFvT6Fuj2HvTyIvkGKvkWJu0yUv2mQrEOKwEWNwkaPxEiNwUqR
xk6Sw06SxU6Uxk+RyVKTxlCUwFKVxVWUwlWWxlKXyFOVzFWWyFaYyFmYx16bwlmZyVicyF2ayFyb
zF2cyV2cz2GaxGSex2GdymGezGOgzGSgyGWgzmihzWmkz22iymyizGmj0Gqk0m2l0HWqz3asznqn
ynuszXKp0XKq1nWp0Xaq1Hes0Xat1Hmt1Xyt0Huw1Xux2IGBgYWFhYqKio6Ojo6Xn5CQkJWVlZiY
mJycnKCgoKCioqKioqSkpKampqmpqaurq62trbGxsbKysrW1tbi4uLq6ur29vYCu0YixzYOw14G0
1oaz14e114K124O03YWz2Ie12oW13Im10o621Ii22oi23Iy32oq52Y252Y+73ZS51Ze81JC625G7
3JG825K83Je72pW93Zq92Zi/35G+4aC90qG+15bA3ZnA3Z7A2pjA4Z/E4qLA2KDF3qTA2qTE3avF
36zG3rLM3aPF4qfJ5KzJ4LPL5LLM5LTO4rbN5bLR6LTR6LXQ6r3T5L3V6cLCwsTExMbGxsvLy8/P
z9HR0dXV1dbW1tjY2Nra2tzc3N7e3sDW5sHV6cTY6MnZ79De7dTg6dTh69Xi7dbj7tni793m7tXj
8Nbk9tjl9N3m9N/p9eHh4eTk5Obm5ujo6Orq6u3t7e7u7uDp8efs8uXs+Ozv8+3z9vDw8PLy8vL0
9/b29vb5+/f6+/j4+Pn6+/r6+vr6/Pn8/fr8/Pv9/vz8/P7+/gAAACH5BAMAAP8ALAAAAAB4ABgA
AAj/AP8JHEiwoMGDCBMqXMiwocOHECNKnEixosWLGDNqZCioo0dC0Q7Sy2btlitisrjpK4io4yF/
yjzKRIZPIDSZOAUVmubxGUF88Aj2K+TxnKKOhfoJdOSxXEF1OXHCi5fnTx5oBgFo3QogwAalAv1V
yyUqFCtVZ2DZceOOIAKtB/pp4Mo1waN/gOjSJXBugFYJBBflIYhsq4F5DLQSmCcwwVZlBZvppQtt
D6M8gUBknQxA879+kXixwtauXbhheFph6dSmnsC3AOLO5TygWV7OAAj8u6A1QEiBEg4PnA2gw7/E
uRn3M7C1WWTcWqHlScahkJ7NkwnE80dqFiVw/Pz5/xMn7MsZLzUsvXoNVy50C7c56y6s1YPNAAAC
CYxXoLdP5IsJtMBWjDwHHTSJ/AENIHsYJMCDD+K31SPymEFLKNeM880xxXxCxhxoUKFJDNv8A5ts
W0EowFYFBFLAizDGmMA//iAnXAdaLaCUIVtFIBCAjP2Do1YNBCnQMwgkqeSSCEjzzyJ/BFJTQfNU
WSU6/Wk1yChjlJKJLcfEgsoaY0ARigxjgKEFJPec6J5WzFQJDwS9xdPQH1sR4k8DWzXijwRbHfKj
YkFO45dWFoCVUTqMMgrNoQD08ckPsaixBRxPKFEDEbEMAYYTSGQRxzpuEueTQBlshc5A6pjj6pQD
wf9DgFYP+MPHVhKQs2Js9gya3EB7cMWBPwL1A8+xyCYLD7EKQSfEF1uMEcsXTiThQhmszBCGC7G0
QAUT1JS61an/pKrVqsBttYxBxDGjzqxd8abVBwMBOZA/xHUmUDQB9OvvvwGYsxBuCNRSxidOwFCH
J5dMgcYJUKjQCwlahDHEL+JqRa65AKD7D6BarVsQM1tpgK9eAjjpa4D3esBVgdFAB4DAzXImiDY5
vCFHESko4cMKSJwAxhgzFLFDHEUYkzEAG6s6EMgAiFzQA4rBIxldExBkr1AcJzBPzNDRnFCKBpTd
gCD/cKKKDFuYQoQVNhhBBSY9TBHCFVW4UMkuSzf/fe7T6h4kyFZ/+BMBXYpoTahB8yiwlSFgdzXA
5JQPIDZCW1FgkDVxgGKCFCywEUQaKNitRA5UXHGFHN30PRDHHkMtNUHzMAcAA/4gwhUCsB63uEF+
bMVB5BVMtFXWBfljBhhgbCFCEyI4EcIRL4ChRgh36LBJPq6j6nS6ISPkslY0wQbAYIr/ahCeWg2f
ufFaIV8QNpeMMAkVlSyRiRNb0DFCFlu4wSlWYaL2mOp13/tY4A7CL63cRQ9aEYBT0seyfsQjHedg
xAG24ofITaBRIGTW2OJ3EH7o4gtfCIETRBAFEYRgC06YAw3CkIqVdK9cCZRdQgCVAKWYwy/FK4i9
3TYQIboE4BmR6wrABBCUmgFAfgXZRxfs4ARPPCEOZJjCHVxABFAA4R3sic2bmIbAv4EvaglJBACu
IxAMAKARBrFXvrhiAX8kEWVNHOETE+IPbzyBCD8oQRZwwIVOyAAXrgkjijRWxo4BLnwIwUcCJvgP
ZShAUfVa3Bz/EpQ70oWJC2mAKDmwEHYAIxhikAQPeOCLdRTEAhGIQKL0IMoGTGMgIBClA9QxkA3U
0hkKgcy9HHEQDcRyAr0ChAWWucwNMIJZ5KilNGvpADtt5JrYzKY2t8nNbnrzm+B8SEAAADs="

  return [image create photo -format GIF -data $logoData]
}

} ;# ![namespace exists pw::DomainsToBc]


#####################################################################
#                           MAIN
#####################################################################
if { ![info exists disableAutoRun_DomainsToBc] } {
  pw::Script loadTk
  pw::DomainsToBc::gui::run
}

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
