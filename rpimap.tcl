package provide rpimap 1.0

namespace eval ::RPIMap:: {
	namespace export rpimap
	
	variable w
	variable v
	variable rpimap
	variable res_nucleics
	variable res_proteins
	variable scroll_height
	variable fst_proteins
	variable fst_nucleics
	variable optionselect
	variable proteinchain ""
	variable nucleicchain ""
	variable proteinchainsel ""
	variable nucleicchainsel ""
}

proc ::RPIMap::rpimap {} {
	variable w
	variable rpimap
	variable optionselect
	variable proteinchainsel
	variable nucleicchainsel
	
	if {[winfo exists .rpimap]} {
		wm deiconify $w
		return
	}
	
	set w [toplevel ".rpimap"]
	wm title $w "RNA-Protein Interface Mapping Tool"
	wm resizable $w 0 0;
	
	canvas $w.header -height 100 -width 650
	canvas $w.main -height 500 -width 650 -scrollregion {0 0 650 500} -yscrollcommand {$::RPIMap::w.scroll set}
	scrollbar $w.scroll -command [list $::RPIMap::w.main yview]
	labelframe $w.options -text Options -width 100 -font {-weight bold}
	radiobutton $w.options.interaction -text "Interaction Map" -variable ::RPIMap::optionselect -value interaction -indicatoron 0
	radiobutton $w.options.amino -text "Protein Map" -variable ::RPIMap::optionselect -value amino -indicatoron 0
	radiobutton $w.options.rna -text "Nucleic Map" -variable ::RPIMap::optionselect -value rna -indicatoron 0
	radiobutton $w.options.statistics -text "Statistics" -variable ::RPIMap::optionselect -value statistics -indicatoron 0
	radiobutton $w.options.proteinstatistics -text "Protein Statistics" -variable ::RPIMap::optionselect -value proteinstat -indicatoron 0
	radiobutton $w.options.nucleicstatistics -text "Nucleic Statistics" -variable ::RPIMap::optionselect -value nucleicstat -indicatoron 0
	label $w.options.proteinlabel -text "Protein Chain"
	ttk::combobox $w.options.protein -values [lsort -unique [[atomselect top "protein"] get chain]] -state readonly -width 3 -textvariable ::RPIMap::proteinchainsel
	label $w.options.nucleiclabel -text "Nucleic Chain"
	ttk::combobox $w.options.nucleic -values [lsort -unique [[atomselect top "nucleic"] get chain]] -state readonly -width 3 -textvariable ::RPIMap::nucleicchainsel
	button $w.options.update -text Update -command ::RPIMap::Update
	labelframe $w.legend -text Legend -width 100 -font {-weight bold}
	canvas $w.legend.legend -width 100 -height 350
	button $w.save -text "Save Main Window" -command ::RPIMap::Save
	button $w.options.visualize -text "Visualization Options" -command ::RPIMap::Visualize
	
	$w.options.protein current 0
	$w.options.nucleic current 0
	
	grid $w.header -column 1 -row 1
	grid $w.main -column 1 -row 2 -rowspan 3
	grid propagate $w.main 0
	grid $w.scroll -column 1 -row 2 -rowspan 3 -sticky nse
	grid $w.options -column 2 -row 1 -rowspan 2 -sticky nsew
	grid $w.options.interaction -in $w.options -column 1 -row 1 -columnspan 2 -sticky ew
	grid $w.options.amino -in $w.options -column 1 -row 2 -columnspan 2 -sticky ew
	grid $w.options.rna -in $w.options -column 1 -row 3 -columnspan 2 -sticky ew
	grid $w.options.statistics -in $w.options -column 1 -row 4 -columnspan 2 -sticky ew
	grid $w.options.proteinstatistics -in $w.options -column 1 -row 5 -columnspan 2 -sticky ew
	grid $w.options.nucleicstatistics -in $w.options -column 1 -row 6 -columnspan 2 -sticky ew
	grid $w.options.proteinlabel -in $w.options -column 1 -row 7
	grid $w.options.protein -in $w.options -column 2 -row 7
	grid $w.options.nucleiclabel -in $w.options -column 1 -row 8
	grid $w.options.nucleic -in $w.options -column 2 -row 8
	grid $w.options.update -in $w.options -column 1 -row 9 -columnspan 2 -sticky ew
	grid $w.options.visualize -in $w.options -column 1 -row 10 -columnspan 2 -sticky ew
	grid $w.legend -column 2 -row 3 -sticky ns
	grid $w.legend.legend -in $w.legend -column 1 -row 1 -sticky ns
	grid $w.save -column 2 -row 4 -sticky nsew
	
	$w.options.interaction select
}

proc ::RPIMap::Update {} {
	variable w
	variable rpimap
	variable optionselect
	variable proteinchain
	variable nucleicchain
	variable proteinchainsel
	variable nucleicchainsel
	
	set ::RPIMap::proteinchain $proteinchainsel
	set ::RPIMap::nucleicchain $nucleicchainsel
	
	if {$optionselect == {interaction}} {
		$w.main delete all
		$w.header delete all
		$w.legend.legend delete all
		::RPIMap::get_resids
		::RPIMap::scrollheight
		set scrollregionlist [list 0 0 650 $::RPIMap::scroll_height]
		$w.main configure -scrollregion $scrollregionlist
		::RPIMap::get_resnames
		::RPIMap::inter_resids
	} elseif {$optionselect == {amino}} {
		$w.main delete all
		$w.header delete all
		$w.legend.legend delete all
		::RPIMap::get_resids
		::RPIMap::scrollheight
		set scrollregionlist [list 0 0 650 $::RPIMap::scroll_height]
		$w.main configure -scrollregion $scrollregionlist
		::RPIMap::AminoMap
	} elseif {$optionselect == {rna}} {
		$w.main delete all
		$w.header delete all
		$w.legend.legend delete all
		::RPIMap::get_resids
		::RPIMap::scrollheight
		set scrollregionlist [list 0 0 650 $::RPIMap::scroll_height]
		$w.main configure -scrollregion $scrollregionlist
		::RPIMap::RNAMap
	} elseif {$optionselect == {statistics}} {
		$w.main delete all
		$w.header delete all
		$w.legend.legend delete all
		::RPIMap::scrollheight
		set scrollregionlist [list 0 0 650 $::RPIMap::scroll_height]
		$w.main configure -scrollregion $scrollregionlist
		::RPIMap::Statistics
	} elseif {$optionselect == {proteinstat}} {
		$w.main delete all
		$w.header delete all
		$w.legend.legend delete all
		::RPIMap::scrollheight
		set scrollregionlist [list 0 0 650 $::RPIMap::scroll_height]
		$w.main configure -scrollregion $scrollregionlist
		::RPIMap::ProteinStats
	} elseif {$optionselect == {nucleicstat}} {
		$w.main delete all
		$w.header delete all
		$w.legend.legend delete all
		::RPIMap::scrollheight
		set scrollregionlist [list 0 0 650 $::RPIMap::scroll_height]
		$w.main configure -scrollregion $scrollregionlist
		::RPIMap::NucleicStats
	} else {
		$w.main delete all
		$w.header delete all
		$w.legend.legend delete all
		::RPIMap::scrollheight
		set scrollregionlist [list 0 0 650 $::RPIMap::scroll_height]
		$w.main configure -scrollregion $scrollregionlist
	}
}

proc ::RPIMap::get_resids {} {
	variable w
	variable rpimap
	variable res_proteins
	variable res_nucleics
	variable fst_nucleics
	variable fst_proteins
	variable proteinchain
	variable nucleicchain
	
	set res_proteins [lsort -unique -integer [[atomselect top "protein and chain ${proteinchain}"] get resid]]
	set res_nucleics [lsort -unique -integer [[atomselect top "nucleic and chain ${nucleicchain}"] get resid]]
	set fst_proteins [lindex $res_proteins 0]
	set fst_nucleics [lindex $res_nucleics 0]
}

proc ::RPIMap::get_resnames {} {
	variable w
	variable rpimap
	variable res_proteins
	variable res_nucleics
	variable fst_nucleics
	variable fst_proteins
	
	::RPIMap::InteractionHead
	::RPIMap::InteractionLegend
	
	foreach protein $::RPIMap::res_proteins {
		::RPIMap::ProteinPDBAtom $protein
		::RPIMap::ProteinSize $protein
		::RPIMap::ProteinStructure $protein
		::RPIMap::ProteinCharge $protein
		::RPIMap::ProteinPolarity $protein
		::RPIMap::ProteinSulfur $protein
		$w.main create text 115 [expr ${protein} * 10 + 10 - $fst_proteins * 10] -text "[lindex [lsort -unique [[atomselect top "protein and resid $protein"] get resname]] 0]"
	}
	
	foreach nucleic $::RPIMap::res_nucleics {
		$w.main create text 595 [expr ${nucleic} * 10 + 10 - $fst_nucleics * 10] -text "[lindex [lsort -unique [[atomselect top "nucleic and resid $nucleic"] get resname]] 0]"
		::RPIMap::NucleicPDBAtom $nucleic
	}
}

proc ::RPIMap::InteractionHead {} {
	variable w
	variable rpimap
	
	$w.header create text 325 75 -text "RNA-PROTEIN INTERACTION MAP" -font {-weight bold}
}

proc ::RPIMap::InteractionLegend {} {
	variable w
	variable rpimap
	
	$w.legend.legend create text 50 10 -text "SIZE"
	$w.legend.legend create text 10 20 -text "S"
	$w.legend.legend create text 60 20 -text "Small"
	$w.legend.legend create text 10 30 -text "M"
	$w.legend.legend create text 60 30 -text "Medium"
	$w.legend.legend create text 10 40 -text "L"
	$w.legend.legend create text 60 40 -text "Large"
	
	$w.legend.legend create text 50 60 -text "STRUCTURE"
	$w.legend.legend create text 10 70 -text "T"
	$w.legend.legend create text 60 70 -text "Turn"
	$w.legend.legend create text 10 80 -text "H"
	$w.legend.legend create text 60 80 -text "Helix"
	$w.legend.legend create text 10 90 -text "S"
	$w.legend.legend create text 60 90 -text "Sheet"
	$w.legend.legend create text 10 100 -text "C"
	$w.legend.legend create text 60 100 -text "Coil"
	
	$w.legend.legend create text 50 120 -text "CHARGE"
	$w.legend.legend create oval 7 127 13 133
	$w.legend.legend create text 60 130 -text "Neutral"
	$w.legend.legend create oval 7 137 13 143 -fill blue
	$w.legend.legend create text 60 140 -text "Basic"
	$w.legend.legend create oval 7 147 13 153 -fill red
	$w.legend.legend create text 60 150 -text "Acidic"
	
	$w.legend.legend create text 50 170 -text "POLARITY"
	$w.legend.legend create oval 7 177 13 183 -fill blue
	$w.legend.legend create text 60 180 -text "Nonpolar"
	$w.legend.legend create oval 7 187 13 193 -fill red
	$w.legend.legend create text 60 190 -text "Polar"
	
	$w.legend.legend create text 50 210 -text "SULFUR"
	$w.legend.legend create oval 7 217 13 223 -fill yellow
	$w.legend.legend create text 60 220 -text "Sulfur"
	$w.legend.legend create oval 7 227 13 233
	$w.legend.legend create text 60 230 -text "No Sulfur"
	
	$w.legend.legend create text 50 250 -text "DISTANCE"
	$w.legend.legend create oval 7 257 13 263 -fill red
	$w.legend.legend create text 60 260 -text "<2 A"
	$w.legend.legend create oval 7 267 13 273 -fill orange
	$w.legend.legend create text 60 270 -text "2-3 A"
	$w.legend.legend create oval 7 277 13 283 -fill yellow
	$w.legend.legend create text 60 280 -text "3-4 A"
	$w.legend.legend create oval 7 287 13 293 -fill khaki
	$w.legend.legend create text 60 290 -text "4-5 A"
}


proc ::RPIMap::ProteinPDBAtom {protein} {
	variable w
	variable rpimap
	variable fst_nucleics
	variable fst_proteins
	
	set x 20
	
	$w.main create text $x [expr ${protein} * 10 + 10 - $fst_proteins * 10] -text $protein
}

proc ::RPIMap::ProteinSize {protein} {
	variable w
	variable rpimap
	variable fst_nucleics
	variable fst_proteins
	
	set x 45
	
	if {[[atomselect top "protein and resid $protein and small"] num] != 0} {
		$w.main create text $x [expr ${protein} * 10 + 10 - $fst_proteins * 10] -text S
	} elseif {[[atomselect top "protein and resid $protein and medium"] num] != 0} {
		$w.main create text $x [expr ${protein} * 10 + 10 - $fst_proteins * 10] -text M
	} else {
		$w.main create text $x [expr ${protein} * 10 + 10 - $fst_proteins * 10] -text L
	}
}

proc ::RPIMap::ProteinStructure {protein} {
	variable w
	variable rpimap
	variable fst_nucleics
	variable fst_proteins
	
	set x 60
	
	$w.main create text $x [expr ${protein} * 10 + 10 - $fst_proteins * 10] -text [lindex [[atomselect top "protein and resid ${protein}"] get structure] 0]
}

proc ::RPIMap::ProteinCharge {protein} {
	variable w
	variable rpimap
	variable fst_nucleics
	variable fst_proteins
	
	set radius 3
	set x 75
	
	if {[[atomselect top "protein and resid $protein and basic"] num] != 0} {
		$w.main create oval [expr $x - $radius] [expr ${protein} * 10 + 10 - $radius - $fst_proteins * 10] [expr $x + $radius] [expr ${protein} * 10 + 10 + $radius - $fst_proteins * 10] -fill blue
	} elseif {[[atomselect top "protein and resid $protein and acidic"] num] != 0} {
		$w.main create oval [expr $x - $radius] [expr ${protein} * 10 + 10 - $radius - $fst_proteins * 10] [expr $x + $radius] [expr ${protein} * 10 + 10 + $radius - $fst_proteins * 10] -fill red
	} else {
		$w.main create oval [expr $x - $radius] [expr ${protein} * 10 + 10 - $radius - $fst_proteins * 10] [expr $x + $radius] [expr ${protein} * 10 + 10 + $radius - $fst_proteins * 10]
	}
}

proc ::RPIMap::ProteinPolarity {protein} {
	variable w
	variable rpimap
	variable fst_nucleics
	variable fst_proteins
	
	set radius 3
	set x 85
	
	if {[[atomselect top "protein and resid $protein and polar"] num] != 0} {
		$w.main create oval [expr $x - $radius] [expr ${protein} * 10 + 10 - $radius - $fst_proteins * 10] [expr $x + $radius] [expr ${protein} * 10 + 10 + $radius - $fst_proteins * 10] -fill blue
	} else {
		$w.main create oval [expr $x - $radius] [expr ${protein} * 10 + 10 - $radius - $fst_proteins * 10] [expr $x + $radius] [expr ${protein} * 10 + 10 + $radius - $fst_proteins * 10] -fill red
	}
}

proc ::RPIMap::ProteinSulfur {protein} {
	variable w
	variable rpimap
	variable fst_nucleics
	variable fst_proteins
	
	set radius 3
	set x 95
	
	if {[[atomselect top "protein and resid $protein and sulfur"] num] != 0} {
		$w.main create oval [expr $x - $radius] [expr ${protein} * 10 + 10 - $radius - $fst_proteins * 10] [expr $x + $radius] [expr ${protein} * 10 + 10 + $radius - $fst_proteins * 10] -fill yellow
	} else {
		$w.main create oval [expr $x - $radius] [expr ${protein} * 10 + 10 - $radius - $fst_proteins * 10] [expr $x + $radius] [expr ${protein} * 10 + 10 + $radius - $fst_proteins * 10]
	}
}

proc ::RPIMap::NucleicPDBAtom {nucleic} {
	variable w
	variable rpimap
	variable fst_nucleics
	variable fst_proteins
	
	set x 620
	
	$w.main create text $x [expr ${nucleic} * 10 + 10 - $fst_nucleics * 10] -text $nucleic
}

proc ::RPIMap::inter_resids {} {
	variable w
	variable rpimap
	variable fst_nucleics
	variable fst_proteins
	variable proteinchain
	variable nucleicchain
	
	set p_resids []
	set n_resids []
	for {set i 0} {$i < 5} {incr i} {
		set k [expr 5 - $i]
		lappend p_resids [lsort -unique -integer [[atomselect top "protein and chain ${proteinchain} and within ${k} of (nucleic and chain ${nucleicchain})"] get resid]]
		lappend n_resids [lsort -unique -integer [[atomselect top "nucleic and chain ${nucleicchain} and within ${k} of (protein and chain ${proteinchain})"] get resid]]
	}
	
	for {set i 0} {$i < 5} {incr i} {
		foreach protein [lindex $p_resids $i] {
			$w.main create oval 127 [expr ${protein} * 10 + 7 - $fst_proteins * 10] 133 [expr ${protein} * 10 + 13 - $fst_proteins * 10] -fill [::RPIMap::color $i]
			if {$i == 0} {
				$w.main create line 135 [expr ${protein} * 10 + 10 - $fst_proteins * 10] 575 [expr [::RPIMap::getclosestnucleic $protein] * 10 + 10 - $fst_nucleics * 10]
			}
		}
		foreach nucleic [lindex $n_resids $i] {
			$w.main create oval 577 [expr ${nucleic} * 10 + 7 - $fst_nucleics * 10] 583 [expr ${nucleic} * 10 + 13 - $fst_nucleics * 10] -fill [::RPIMap::color $i]
			if {$i == 0} {
				$w.main create line 575 [expr ${nucleic} * 10 + 10 - $fst_nucleics * 10] 135 [expr [::RPIMap::getclosestprotein $nucleic] * 10 + 10 - $fst_proteins * 10]
			}
		}
	}
}

proc ::RPIMap::color {value} {
	if {$value == 0} {
		return khaki
	} elseif {$value == 1} {
		return yellow
	} elseif {$value == 2} {
		return orange
	} elseif {$value == 3} {
		return red
	} elseif {$value == 4} {
		return black
	}
}

proc ::RPIMap::AminoMap {} {
	variable w
	variable rpimap
	variable proteinchain
	variable nucleicchain
	
	$w.header create text 320 75 -text "AMINO ACID CIRCLE MAP" -font {-weight bold}
	
	$w.legend.legend create text 50 10 -text "DISTANCE"
	$w.legend.legend create oval 7 17 13 23 -fill red
	$w.legend.legend create text 60 20 -text "<2 A"
	$w.legend.legend create oval 7 27 13 33 -fill orange
	$w.legend.legend create text 60 30 -text "2-3 A"
	$w.legend.legend create oval 7 37 13 43 -fill yellow
	$w.legend.legend create text 60 40 -text "3-4 A"
	$w.legend.legend create oval 7 47 13 53 -fill khaki
	$w.legend.legend create text 60 50 -text "4-5 A"
	
	set proteins [lsort -unique -integer [[atomselect top "protein and chain ${proteinchain}"] get resid]]
	if {[llength $proteins] < 80} {
		set p_resids []
		
		for {set i 0} {$i < 5} {incr i} {
			set k [expr 5 - $i]
			lappend p_resids [lsort -unique -integer [[atomselect top "protein and chain ${proteinchain} and within ${k} of nucleic"] get resid]]
		}
		
		for {set i 0} {$i < [llength $proteins]} {incr i} {
			set float [expr {double($i)}]
			$w.main create text [expr 185 * sin((2*3.1415*($float+0.5))/[llength $proteins]) + 250] [expr -185 * cos((-2*3.1415*($float+0.5))/[llength $proteins]) + 250] -text "[lindex $proteins $i]\n[lsort -unique [[atomselect top "protein and resid [lindex $proteins $i]"] get resname]]"
			
			if {$i != 0} {
				$w.main create line [expr 165 * sin((2*3.1415*($float+0.5))/[llength $proteins]) + 250] [expr -165 * cos((-2*3.1415*($float+0.5))/[llength $proteins]) + 250] [expr 165 * sin((2*3.1415*(($float+0.5) - 1))/[llength $proteins]) + 250] [expr -165 * cos((-2*3.1415*(($float+0.5) - 1))/[llength $proteins]) + 250]
			}
			$w.main create oval [expr 165 * sin((2*3.1415*($float+0.5))/[llength $proteins]) + 247] [expr -165 * cos((-2*3.1415*($float+0.5))/[llength $proteins]) + 247] [expr 165 * sin((2*3.1415*($float+0.5))/[llength $proteins]) + 253] [expr -165 * cos((-2*3.1415*($float+0.5))/[llength $proteins]) + 253]
			
			
			if {[[atomselect top "nucleic and chain ${nucleicchain} and within 5 of (protein and chain ${proteinchain} and resid [lindex $proteins $i])"] num] != 0} {
				set nucleicsel [[atomselect top "nucleic and chain ${nucleicchain} and resid [::RPIMap::getclosestnucleic [lindex $proteins $i]]"] get resname]
				$w.main create text [expr 235 * sin((2*3.1415*($float+0.5))/[llength $proteins]) + 250] [expr -235 * cos((-2*3.1415*($float+0.5))/[llength $proteins]) + 250] -text "[::RPIMap::getclosestnucleic [lindex $proteins $i]]\n[lsort -unique $nucleicsel]"
				
				set colorvalue 0
				for {set k 4} {$k > 0} {incr k -1} {
					if {[lsearch -exact [lindex $p_resids $k] [lindex $proteins $i]] != -1} {
						set colorvalue $k
						break
					}
				}
				$w.main create oval [expr 210 * sin((2*3.1415*($float+0.5))/[llength $proteins]) + 247] [expr -210 * cos((-2*3.1415*($float+0.5))/[llength $proteins]) + 247] [expr 210* sin((2*3.1415*($float+0.5))/[llength $proteins]) + 253] [expr -210 * cos((-2*3.1415*($float+0.5))/[llength $proteins]) + 253] -fill [::RPIMap::color $colorvalue]
			}
		}
		
		for {set i 0} {$i < 5} {incr i} {
			set hbondslist [measure hbonds 3.0 40 [atomselect top "protein and chain ${proteinchain}"]]
			for {set i 0} {$i < [llength [lindex $hbondslist 0]]} {incr i} {
				set donor [lsearch -exact $proteins [lsort -unique [[atomselect top "protein and chain ${proteinchain} and index [lindex [lindex $hbondslist 0] $i]"] get resid]]]
				set acceptor [lsearch -exact $proteins [lsort -unique [[atomselect top "protein and chain ${proteinchain} and index [lindex [lindex $hbondslist 1] $i]"] get resid]]]
				$w.main create line [expr 165 * sin((2*3.1415*($donor+0.5))/[llength $proteins]) + 250] [expr -165 * cos((-2*3.1415*($donor+0.5))/[llength $proteins]) + 250] [expr 165 * sin((2*3.1415*($acceptor+0.5))/[llength $proteins]) + 250] [expr -165 * cos((-2*3.1415*(($acceptor+0.5)))/[llength $proteins]) + 250] -dash .
			}
		}
	} else {
		$w.main create text 325 250 -text "Protein Chain is too long!"
	}
}

proc ::RPIMap::RNAMap {} {
	variable w
	variable rpimap
	variable proteinchain
	variable nucleicchain
	
	$w.header create text 320 75 -text "RNA CIRCLE MAP" -font {-weight bold}
	
	$w.legend.legend create text 50 10 -text "DISTANCE"
	$w.legend.legend create oval 7 17 13 23 -fill red
	$w.legend.legend create text 60 20 -text "<2 A"
	$w.legend.legend create oval 7 27 13 33 -fill orange
	$w.legend.legend create text 60 30 -text "2-3 A"
	$w.legend.legend create oval 7 37 13 43 -fill yellow
	$w.legend.legend create text 60 40 -text "3-4 A"
	$w.legend.legend create oval 7 47 13 53 -fill khaki
	$w.legend.legend create text 60 50 -text "4-5 A"
	
	set nucleics [lsort -unique -integer [[atomselect top "nucleic and chain ${nucleicchain}"] get resid]]
	if {[llength $nucleics] < 40} {
		set n_resids []
		
		for {set i 0} {$i < 5} {incr i} {
			set k [expr 5 - $i]
			lappend n_resids [lsort -unique -integer [[atomselect top "nucleic and chain ${nucleicchain} and within ${k} of protein"] get resid]]
		}
		
		for {set i 0} {$i < [llength $nucleics]} {incr i} {
			set float [expr {double($i)}]
			$w.main create text [expr 185 * sin((2*3.1415*($float+0.5))/[llength $nucleics]) + 250] [expr -185 * cos((-2*3.1415*($float+0.5))/[llength $nucleics]) + 250] -text "[lindex $nucleics $i]\n[lsort -unique [[atomselect top "nucleic and resid [lindex $nucleics $i]"] get resname]]"
			
			if {$i != 0} {
				$w.main create line [expr 165 * sin((2*3.1415*($float+0.5))/[llength $nucleics]) + 250] [expr -165 * cos((-2*3.1415*($float+0.5))/[llength $nucleics]) + 250] [expr 165 * sin((2*3.1415*(($float+0.5) - 1))/[llength $nucleics]) + 250] [expr -165 * cos((-2*3.1415*(($float+0.5) - 1))/[llength $nucleics]) + 250]
			}
			$w.main create oval [expr 165 * sin((2*3.1415*($float+0.5))/[llength $nucleics]) + 247] [expr -165 * cos((-2*3.1415*($float+0.5))/[llength $nucleics]) + 247] [expr 165 * sin((2*3.1415*($float+0.5))/[llength $nucleics]) + 253] [expr -165 * cos((-2*3.1415*($float+0.5))/[llength $nucleics]) + 253]
			
			
			if {[[atomselect top "protein and chain ${proteinchain} and within 5 of (nucleic and chain ${nucleicchain} and resid [lindex $nucleics $i])"] num] != 0} {
				set proteinsel [[atomselect top "protein and chain ${proteinchain} and resid [::RPIMap::getclosestprotein [lindex $nucleics $i]]"] get resname]
				$w.main create text [expr 235 * sin((2*3.1415*($float+0.5))/[llength $nucleics]) + 250] [expr -235 * cos((-2*3.1415*($float+0.5))/[llength $nucleics]) + 250] -text "[::RPIMap::getclosestprotein [lindex $nucleics $i]]\n[lsort -unique $proteinsel]"
				
				set colorvalue 0
				for {set k 4} {$k > 0} {incr k -1} {
					if {[lsearch -exact [lindex $n_resids $k] [lindex $nucleics $i]] != -1} {
						set colorvalue $k
						break
					}
				}
				$w.main create oval [expr 210 * sin((2*3.1415*($float+0.5))/[llength $nucleics]) + 247] [expr -210 * cos((-2*3.1415*($float+0.5))/[llength $nucleics]) + 247] [expr 210* sin((2*3.1415*($float+0.5))/[llength $nucleics]) + 253] [expr -210 * cos((-2*3.1415*($float+0.5))/[llength $nucleics]) + 253] -fill [::RPIMap::color $colorvalue]
			}
		}
		
		for {set i 0} {$i < 5} {incr i} {
			set hbondslist [measure hbonds 3.0 40 [atomselect top "nucleic and chain ${nucleicchain}"]]
			for {set i 0} {$i < [llength [lindex $hbondslist 0]]} {incr i} {
				set donor [lsearch -exact $nucleics [lsort -unique [[atomselect top "nucleic and chain ${nucleicchain} and index [lindex [lindex $hbondslist 0] $i]"] get resid]]]
				set acceptor [lsearch -exact $nucleics [lsort -unique [[atomselect top "nucleic and chain ${nucleicchain} and index [lindex [lindex $hbondslist 1] $i]"] get resid]]]
				$w.main create line [expr 165 * sin((2*3.1415*($donor+0.5))/[llength $nucleics]) + 250] [expr -165 * cos((-2*3.1415*($donor+0.5))/[llength $nucleics]) + 250] [expr 165 * sin((2*3.1415*($acceptor+0.5))/[llength $nucleics]) + 250] [expr -165 * cos((-2*3.1415*(($acceptor+0.5)))/[llength $nucleics]) + 250] -dash .
			}
		}
	} else {
		$w.main create text 325 250 -text "RNA Chain is too long!"
	}
}

proc ::RPIMap::Statistics {} {
	variable w
	variable rpimap
	
	$w.header create text 320 75 -text "RNA-PROTEIN INTERACTION STATISTICS" -font {-weight bold}
	
	::RPIMap::SASA
	::RPIMap::Mass
	::RPIMap::ResidueCt
	::RPIMap::AtomCt
	::RPIMap::ChrgCt
	::RPIMap::PolarCt
	::RPIMap::SulfCt
	::RPIMap::InterCt
}

proc ::RPIMap::SASA {} {
	variable w
	variable rpimap
	variable proteinchain
	variable nucleicchain
	
	$w.main create text 350 10 -text "Solvent Accessible Surface Area Calculations" -font {-weight bold}
	set sasa_protein [measure sasa 1.4 [atomselect top "protein and chain ${proteinchain}"]]
	set sasa_nucleic [measure sasa 1.4 [atomselect top "nucleic and chain ${nucleicchain}"]]
	set sasa_total [measure sasa 1.4 [atomselect top "(protein and chain ${proteinchain}) or (nucleic and chain ${nucleicchain})"]]
	$w.main create text 10 30 -anchor w -text "Interficial Area:"
	$w.main create text 600 30 -anchor e -text [format "%#.3f A^2" [expr $sasa_protein + $sasa_nucleic - $sasa_total]]
	$w.main create text 10 40 -anchor w -text "Interficial Area % for Protein SASA:"
	$w.main create text 600 40 -anchor e -text [format "%#.3f %c" [expr double(100 * ($sasa_protein + $sasa_nucleic - $sasa_total) / $sasa_protein)] 37]
	$w.main create text 10 50 -anchor w -text "Interficial Area % for RNA SASA:"
	$w.main create text 600 50 -anchor e -text [format "%#.3f %c" [expr double(100 * ($sasa_protein + $sasa_nucleic - $sasa_total) / $sasa_nucleic)] 37]
}

proc ::RPIMap::Mass {} {
	variable w
	variable rpimap
	variable proteinchain
	variable nucleicchain
	
	$w.main create text 350 90 -text "Mass Calculations" -font {-weight bold}
	set massproteininter [expr [join [[atomselect top "protein and chain ${proteinchain} and within 5 of nucleic"] get mass] +]]
	set massnucleicinter [expr [join [[atomselect top "nucleic and chain ${nucleicchain} and within 5 of protein"] get mass] +]]
	$w.main create text 10 110 -anchor w -text "Interficial Protein Mass:"
	$w.main create text 600 110 -anchor e -text [format "%#.3f AMU" [expr $massproteininter]]
	$w.main create text 10 120 -anchor w -text "Interficial RNA Mass:"
	$w.main create text 600 120 -anchor e -text [format "%#.3f AMU" [expr $massnucleicinter]]
	$w.main create text 10 130 -anchor w -text "Interficial Mass % for Protein:"
	$w.main create text 600 130 -anchor e -text [format "%#.3f %c" [expr double(100 * $massproteininter / [expr [join [[atomselect top "protein and chain ${proteinchain}"] get mass] +]])] 37]
	$w.main create text 10 140 -anchor w -text "Interficial Mass % for RNA:"
	$w.main create text 600 140 -anchor e -text [format "%#.3f %c" [expr double(100 * $massnucleicinter / [expr [join [[atomselect top "nucleic and chain ${nucleicchain}"] get mass] +]])] 37]
	
}

proc ::RPIMap::ResidueCt {} {
	variable w
	variable rpimap
	variable proteinchain
	variable nucleicchain
	
	$w.main create text 350 170 -text "Residue Count Calculations" -font {-weight bold}
	set resproteininter [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and within 5 of nucleic"] get resid]]]
	set resnucleicinter [llength [lsort -unique [[atomselect top "nucleic and chain ${nucleicchain} and within 5 of protein"] get resid]]]
	$w.main create text 10 180 -anchor w -text "Interficial Protein Residue Count:"
	$w.main create text 600 180 -anchor e -text "[expr $resproteininter]"
	$w.main create text 10 190 -anchor w -text "Interficial RNA Residue Count:"
	$w.main create text 600 190 -anchor e -text "[expr $resnucleicinter]"
	$w.main create text 10 200 -anchor w -text "Interficial Residue Count % for Protein:"
	$w.main create text 600 200 -anchor e -text [format "%#.3f %c" [expr double(100 * $resproteininter / [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain}"] get resid]]])] 37]
	$w.main create text 10 210 -anchor w -text "Interficial Residue Count % for RNA:"
	$w.main create text 600 210 -anchor e -text [format "%#.3f %c" [expr double(100 * $resnucleicinter / [llength [lsort -unique [[atomselect top "nucleic and chain ${nucleicchain}"] get resid]]])] 37]
}

proc ::RPIMap::AtomCt {} {
	variable w
	variable rpimap
	variable proteinchain
	variable nucleicchain
	
	$w.main create text 350 240 -text "Atom Count Calculations" -font {-weight bold}
	set atomproteininter [llength [[atomselect top "protein and chain ${proteinchain} and within 5 of nucleic"] get name]]
	set atomnucleicinter [llength [[atomselect top "nucleic and chain ${nucleicchain} and within 5 of protein"] get name]]
	$w.main create text 10 260 -anchor w -text "Interficial Protein Atom Count:"
	$w.main create text 600 260 -anchor e -text "[expr $atomproteininter]"
	$w.main create text 10 270 -anchor w -text "Interficial RNA Atom Count:"
	$w.main create text 600 270 -anchor e -text "[expr $atomnucleicinter]"
	$w.main create text 10 280 -anchor w -text "Interficial Atom Count % for Protein:"
	$w.main create text 600 280 -anchor e -text [format "%#.3f %c" [expr double(100 * $atomproteininter / [llength [[atomselect top "protein and chain ${proteinchain}"] get name]])] 37]
	$w.main create text 10 290 -anchor w -text "Interficial Atom Count % for RNA:"
	$w.main create text 600 290 -anchor e -text [format "%#.3f %c" [expr double(100 * $atomnucleicinter / [llength [[atomselect top "nucleic and chain ${nucleicchain}"] get name]])] 37]
}

proc ::RPIMap::ChrgCt {} {
	variable w
	variable rpimap
	variable proteinchain
	
	$w.main create text 350 320 -text "Protein Charge Count Calculations" -font {-weight bold}
	set basicproteininter [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and basic and within 5 of nucleic"] get resid]]]
	set acidproteininter [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and acidic and within 5 of nucleic"] get resid]]]
	$w.main create text 10 340 -anchor w -text "Interficial Protein Basic Residue Count:"
	$w.main create text 600 340 -anchor e -text "$basicproteininter"
	$w.main create text 10 350 -anchor w -text "Interficial Protein Acidic Residue Count:"
	$w.main create text 600 350 -anchor e -text "$acidproteininter"
	$w.main create text 10 360 -anchor w -text "Interficial Residue % for Basic Protein Residues:"
	$w.main create text 600 360 -anchor e -text [format "%#.3f %c" [expr double(100 * $basicproteininter / [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and basic"] get resid]]])] 37]
	$w.main create text 10 370 -anchor w -text "Interficial Residue % for Acidic Protein Residues:"
	$w.main create text 600 370 -anchor e -text [format "%#.3f %c" [expr double(100 * $acidproteininter / [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and acidic"] get resid]]])] 37]
}

proc ::RPIMap::PolarCt {} {
	variable w
	variable rpimap
	variable proteinchain
	
	$w.main create text 350 400 -text "Protein Polarity Count Calculations" -font {-weight bold}
	set polproteininter [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and polar and within 5 of nucleic"] get resid]]]
	set nopolproteininter [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and (not polar) and within 5 of nucleic"] get resid]]]
	$w.main create text 10 420 -anchor w -text "Interficial Protein Polar Residue Count:"
	$w.main create text 600 420 -anchor e -text "$polproteininter"
	$w.main create text 10 430 -anchor w -text "Interficial Protein Nonpolar Residue Count:"
	$w.main create text 600 430 -anchor e -text "$nopolproteininter"
	$w.main create text 10 440 -anchor w -text "Interficial Residue % for Polar Protein Residues:"
	$w.main create text 600 440 -anchor e -text [format "%#.3f %c" [expr double(100 * $polproteininter / [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and polar"] get resid]]])] 37]
	$w.main create text 10 450 -anchor w -text "Interficial Residue % for Nonpolar Protein Residues:"
	$w.main create text 600 450 -anchor e -text [format "%#.3f %c" [expr double(100 * $nopolproteininter / [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and (not polar)"] get resid]]])] 37]
}

proc ::RPIMap::SulfCt {} {
	variable w
	variable rpimap
	variable proteinchain
	
	$w.main create text 350 480 -text "Protein Sulfur Containing Count Calculations" -font {-weight bold}
	set sulfproteininter [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and sulfur and within 5 of nucleic"] get resid]]]
	$w.main create text 10 500 -anchor w -text "Interficial Protein Sulfur Containing Residue Count:"
	$w.main create text 600 500 -anchor e -text "$sulfproteininter"
	$w.main create text 10 510 -anchor w -text "Interficial Residue % for Sulfur Containing Protein Residues:"
	if {[llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and sulfur"] get resid]]] == 0} {
		$w.main create text 600 510 -anchor e -text "N/A"
	} else {
		$w.main create text 600 510 -anchor e -text [format "%#.3f %c" [expr double(100 * $sulfproteininter / [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and sulfur"] get resid]]])] 37]
	}
}

proc ::RPIMap::InterCt {} {
	variable w
	variable rpimap
	variable proteinchain
	variable nucleicchain
	
	$w.main create text 350 540 -text "Total Number of Unique Interactions" -font {-weight bold}
	set proteins [lsort -unique [[atomselect top "protein and chain ${proteinchain} and within 5 of nucleic"] get resid]]
	set nucleics [lsort -unique [[atomselect top "nucleic and chain ${nucleicchain} and within 5 of protein"] get resid]]
	set proteinsall [lsort -unique [[atomselect top "protein and chain ${proteinchain}"] get resid]]
	set nucleicsall [lsort -unique [[atomselect top "nucleic and chain ${nucleicchain}"] get resid]]
	set bondsprna []
	foreach protein $proteins {
		set bond [::RPIMap::getclosestprotein $protein]
		lappend bondsprna [list $protein $bond]
	}
	foreach nucleic $nucleics {
		set bond [::RPIMap::getclosestnucleic $nucleic]
		lappend bondsprna [list $bond $nucleic]
	}
	$w.main create text 10 560 -anchor w -text "Number of Unique Interactions:"
	$w.main create text 600 560 -anchor e -text [llength [lsort -unique $bondsprna]]
	$w.main create text 10 570 -anchor w -text "% of Unique Interactions of Possible Unique Interactions:"
	$w.main create text 600 570 -anchor e -text [format "%#.3f %c" [expr double(100 * [llength [lsort -unique $bondsprna]] / ([llength $nucleicsall] + [llength $proteinsall]))] 37]
}

proc ::RPIMap::ProteinStats {} {
	variable w
	variable rpimap
	variable proteinchain
	variable nucleicchain
	
	$w.header create text 320 75 -text "AMINO ACID STATISTICS" -font {-weight bold}
	
	set aminoindex [lsort {ARG LYS ASP GLU GLN ASN HIS SER THR TYR CYS MET TRP ALA ILE LEU PHE VAL PRO GLY}]
	set proteinmin {{0.1 0.2 0.3} {0.1 0.2 0.3} {0.1 0.2 0.3} {0.1 0.2 0.3} {0.1 0.2 0.3} {0.1 0.2 0.3} {0.1 0.2 0.3} {0.1 0.2 0.3} {0.1 0.2 0.3} {0.1 0.2 0.3} {0.1 0.2 0.3} {0.1 0.2 0.3} {0.1 0.2 0.3} {0.1 0.2 0.3} {0.1 0.2 0.3} {0.1 0.2 0.3} {0.1 0.2 0.3} {0.1 0.2 0.3} {0.1 0.2 0.3} {0.1 0.2 0.3}}
	set proteinmean {{0.2 0.4 0.5} {0.2 0.4 0.5} {0.2 0.4 0.5} {0.2 0.4 0.5} {0.2 0.4 0.5} {0.2 0.4 0.5} {0.2 0.4 0.5} {0.2 0.4 0.5} {0.2 0.4 0.5} {0.2 0.4 0.5} {0.2 0.4 0.5} {0.2 0.4 0.5} {0.2 0.4 0.5} {0.2 0.4 0.5} {0.2 0.4 0.5} {0.2 0.4 0.5} {0.2 0.4 0.5} {0.2 0.4 0.5} {0.2 0.4 0.5} {0.2 0.4 0.5}}
	set proteinmax {{0.3 0.5 0.8} {0.3 0.5 0.8} {0.3 0.5 0.8} {0.3 0.5 0.8} {0.3 0.5 0.8} {0.3 0.5 0.8} {0.3 0.5 0.8} {0.3 0.5 0.8} {0.3 0.5 0.8} {0.3 0.5 0.8} {0.3 0.5 0.8} {0.3 0.5 0.8} {0.3 0.5 0.8} {0.3 0.5 0.8} {0.3 0.5 0.8} {0.3 0.5 0.8} {0.3 0.5 0.8} {0.3 0.5 0.8} {0.3 0.5 0.8} {0.3 0.5 0.8}}
	for {set i 0} {$i < 20} {incr i} {
		$w.main create text 10 [expr 60 + 150 * $i] -anchor w -text "[lindex $aminoindex $i]"
		$w.main create text 50 [expr 10 + 150 * $i] -anchor w -text "1.0"
		$w.main create text 50 [expr 30 + 150 * $i] -anchor w -text "0.8"
		$w.main create text 50 [expr 50 + 150 * $i] -anchor w -text "0.6"
		$w.main create text 50 [expr 70 + 150 * $i] -anchor w -text "0.4"
		$w.main create text 50 [expr 90 + 150 * $i] -anchor w -text "0.2"
		$w.main create text 50 [expr 110 + 150 * $i] -anchor w -text "0.0"
		$w.main create line 70 [expr 10 + 150 * $i] 70 [expr 110 + 150 * $i]
		$w.main create line 70 [expr 110 + 150 * $i] 580 [expr 110 + 150 * $i]
		$w.main create rectangle 90 [expr 110 + 150 * $i] 140 [expr 110 + 150 * $i - 100 * [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and resname [lindex $aminoindex $i]"] get resid]]] / [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain}"] get resid]]]] -fill green
		$w.main create text 115 [expr 130 + 150 * $i] -text [format "%#.3f / %#d" [expr double([llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and resname [lindex $aminoindex $i]"] get resid]]]) / [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain}"] get resid]]]] [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and resname [lindex $aminoindex $i]"] get resid]]]]
		$w.main create rectangle 160 [expr 110 + 150 * $i] 210 [expr 110 + 150 * $i - 100 * [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and resname [lindex $aminoindex $i] and within 5 of (nucleic and chain ${nucleicchain})"] get resid]]] / [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and within 5 of (nucleic and chain ${nucleicchain})"] get resid]]]] -fill blue
		$w.main create text 185 [expr 130 + 150 * $i] -text [format "%#.3f / %#d" [expr double([llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and resname [lindex $aminoindex $i] and within 5 of (nucleic and chain ${nucleicchain})"] get resid]]]) / [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and within 5 of (nucleic and chain ${nucleicchain})"] get resid]]]] [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and resname [lindex $aminoindex $i] and within 5 of (nucleic and chain ${nucleicchain})"] get resid]]]]
		if {[llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and resname [lindex $aminoindex $i]"] get resid]]] != 0} {
			$w.main create rectangle 230 [expr 110 + 150 * $i] 280 [expr 110 + 150 * $i - 100 * [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and resname [lindex $aminoindex $i] and within 5 of (nucleic and chain ${nucleicchain})"] get resid]]] / [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and resname [lindex $aminoindex $i]"] get resid]]]] -fill red
			$w.main create text 255 [expr 130 + 150 * $i] -text [format "%#.3f" [expr double([llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and resname [lindex $aminoindex $i] and within 5 of (nucleic and chain ${nucleicchain})"] get resid]]]) / [llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and resname [lindex $aminoindex $i]"] get resid]]]]]
		} else {
			$w.main create rectangle 230 [expr 110 + 150 * $i] 280 [expr 110 + 150 * $i] -fill red
			$w.main create text 255 [expr 130 + 150 * $i] -text "N/A"
		}
		$w.main create rectangle 320 [expr 110 + 150 * $i] 370 [expr 110 + 150 * $i - 100 * [llength [lsort -unique [[atomselect top "protein and resname [lindex $aminoindex $i]"] get resid]]] / [llength [lsort -unique [[atomselect top "protein"] get resid]]]] -fill green
		$w.main create text 345 [expr 130 + 150 * $i] -text [format "%#.3f / %#d" [expr double([llength [lsort -unique [[atomselect top "protein and resname [lindex $aminoindex $i]"] get resid]]]) / [llength [lsort -unique [[atomselect top "protein"] get resid]]]] [llength [lsort -unique [[atomselect top "protein and resname [lindex $aminoindex $i]"] get resid]]]]
		$w.main create rectangle 400 [expr 110 + 150 * $i] 450 [expr 110 + 150 * $i - 100 * [llength [lsort -unique [[atomselect top "protein and resname [lindex $aminoindex $i] and within 5 of (nucleic)"] get resid]]] / [llength [lsort -unique [[atomselect top "protein and within 5 of (nucleic)"] get resid]]]] -fill blue
		$w.main create text 425 [expr 130 + 150 * $i] -text [format "%#.3f / %#d" [expr double([llength [lsort -unique [[atomselect top "protein and resname [lindex $aminoindex $i] and within 5 of (nucleic)"] get resid]]]) / [llength [lsort -unique [[atomselect top "protein and within 5 of (nucleic)"] get resid]]]] [llength [lsort -unique [[atomselect top "protein and resname [lindex $aminoindex $i] and within 5 of (nucleic)"] get resid]]]]
		if {[llength [lsort -unique [[atomselect top "protein and chain ${proteinchain} and resname [lindex $aminoindex $i]"] get resid]]] != 0} {
			$w.main create rectangle 480 [expr 110 + 150 * $i] 530 [expr 110 + 150 * $i - 100 * [llength [lsort -unique [[atomselect top "protein and resname [lindex $aminoindex $i] and within 5 of (nucleic)"] get resid]]] / [llength [lsort -unique [[atomselect top "protein and resname [lindex $aminoindex $i]"] get resid]]]] -fill red
			$w.main create text 505 [expr 130 + 150 * $i] -text [format "%#.3f" [expr double([llength [lsort -unique [[atomselect top "protein and resname [lindex $aminoindex $i] and within 5 of (nucleic)"] get resid]]]) / [llength [lsort -unique [[atomselect top "protein and resname [lindex $aminoindex $i]"] get resid]]]]]
		} else {
			$w.main create rectangle 480 [expr 110 + 150 * $i] 530 [expr 110 + 150 * $i] -fill red
			$w.main create text 505 [expr 130 + 150 * $i] -text "N/A"
		}
		$w.main create line 380 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmin $i] 0]] 380 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmax $i] 0]] -fill red
		$w.main create line 375 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmean $i] 0]] 380 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmean $i] 0]] -fill red
		$w.main create line 375 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmin $i] 0]] 380 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmin $i] 0]] -fill red
		$w.main create line 375 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmax $i] 0]] 380 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmax $i] 0]] -fill red
		$w.main create line 460 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmin $i] 1]] 460 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmax $i] 1]] -fill red
		$w.main create line 455 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmean $i] 1]] 460 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmean $i] 1]] -fill red
		$w.main create line 455 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmin $i] 1]] 460 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmin $i] 1]] -fill red
		$w.main create line 455 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmax $i] 1]] 460 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmax $i] 1]] -fill red
		$w.main create line 540 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmin $i] 2]] 540 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmax $i] 2]] -fill red
		$w.main create line 535 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmean $i] 2]] 540 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmean $i] 2]] -fill red
		$w.main create line 535 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmin $i] 2]] 540 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmin $i] 2]] -fill red
		$w.main create line 535 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmax $i] 2]] 540 [expr 110 + 150 * $i - 100 * [lindex [lindex $proteinmax $i] 2]] -fill red
	}
}

proc ::RPIMap::NucleicStats {} {
	variable w
	variable rpimap
	variable proteinchain
	variable nucleicchain
	
	$w.header create text 320 75 -text "NUCLEIC ACID STATISTICS" -font {-weight bold}
	set nucleicmin {{0.1 0.2 0.3} {0.1 0.2 0.3} {0.1 0.2 0.3} {0.1 0.2 0.3}}
	set nucleicmean {{0.2 0.4 0.5} {0.2 0.4 0.5} {0.2 0.4 0.5} {0.2 0.4 0.5}}
	set nucleicmax {{0.3 0.5 0.8} {0.3 0.5 0.8} {0.3 0.5 0.8} {0.3 0.5 0.8}}
	set nucleicindex [lsort {A C G U}]
	for {set i 0} {$i < 4} {incr i} {
		$w.main create text 10 [expr 60 + 150 * $i] -anchor w -text "[lindex $nucleicindex $i]"
		$w.main create text 50 [expr 10 + 150 * $i] -anchor w -text "1.0"
		$w.main create text 50 [expr 30 + 150 * $i] -anchor w -text "0.8"
		$w.main create text 50 [expr 50 + 150 * $i] -anchor w -text "0.6"
		$w.main create text 50 [expr 70 + 150 * $i] -anchor w -text "0.4"
		$w.main create text 50 [expr 90 + 150 * $i] -anchor w -text "0.2"
		$w.main create text 50 [expr 110 + 150 * $i] -anchor w -text "0.0"
		$w.main create line 70 [expr 10 + 150 * $i] 70 [expr 110 + 150 * $i]
		$w.main create line 70 [expr 110 + 150 * $i] 580 [expr 110 + 150 * $i]
		$w.main create rectangle 90 [expr 110 + 150 * $i] 140 [expr 110 + 150 * $i - 100 * [llength [lsort -unique [[atomselect top "nucleic and chain ${nucleicchain} and resname [lindex $nucleicindex $i]"] get resid]]] / [llength [lsort -unique [[atomselect top "nucleic and chain ${nucleicchain}"] get resid]]]] -fill green
		$w.main create text 115 [expr 130 + 150 * $i] -text [format "%#.3f / %#d" [expr double([llength [lsort -unique [[atomselect top "nucleic and chain ${nucleicchain} and resname [lindex $nucleicindex $i]"] get resid]]]) / [llength [lsort -unique [[atomselect top "nucleic and chain ${nucleicchain}"] get resid]]]] [llength [lsort -unique [[atomselect top "nucleic and chain ${nucleicchain} and resname [lindex $nucleicindex $i]"] get resid]]]]
		$w.main create rectangle 160 [expr 110 + 150 * $i] 210 [expr 110 + 150 * $i - 100 * [llength [lsort -unique [[atomselect top "nucleic and chain ${nucleicchain} and resname [lindex $nucleicindex $i] and within 5 of (protein and chain ${proteinchain})"] get resid]]] / [llength [lsort -unique [[atomselect top "nucleic and chain ${nucleicchain} and within 5 of (protein and chain ${proteinchain})"] get resid]]]] -fill blue
		$w.main create text 185 [expr 130 + 150 * $i] -text [format "%#.3f / %#d" [expr double([llength [lsort -unique [[atomselect top "nucleic and chain ${nucleicchain} and resname [lindex $nucleicindex $i] and within 5 of (protein and chain ${proteinchain})"] get resid]]]) / [llength [lsort -unique [[atomselect top "nucleic and chain ${nucleicchain} and within 5 of (protein and chain ${proteinchain})"] get resid]]]] [llength [lsort -unique [[atomselect top "nucleic and chain ${nucleicchain} and resname [lindex $nucleicindex $i] and within 5 of (protein and chain ${proteinchain})"] get resid]]]]
		if {[llength [lsort -unique [[atomselect top "nucleic and chain ${nucleicchain} and resname [lindex $nucleicindex $i]"] get resid]]] != 0} {
			$w.main create rectangle 230 [expr 110 + 150 * $i] 280 [expr 110 + 150 * $i - 100 * [llength [lsort -unique [[atomselect top "nucleic and chain ${nucleicchain} and resname [lindex $nucleicindex $i] and within 5 of (protein and chain ${proteinchain})"] get resid]]] / [llength [lsort -unique [[atomselect top "nucleic and chain ${nucleicchain} and resname [lindex $nucleicindex $i]"] get resid]]]] -fill red
			$w.main create text 255 [expr 130 + 150 * $i] -text [format "%#.3f" [expr double([llength [lsort -unique [[atomselect top "nucleic and chain ${nucleicchain} and resname [lindex $nucleicindex $i] and within 5 of (protein and chain ${proteinchain})"] get resid]]]) / [llength [lsort -unique [[atomselect top "nucleic and chain ${nucleicchain} and resname [lindex $nucleicindex $i]"] get resid]]]]]
		} else {
			$w.main create rectangle 230 [expr 110 + 150 * $i] 280 [expr 110 + 150 * $i] -fill red
			$w.main create text 255 [expr 130 + 150 * $i] -text "N/A"
		}
		$w.main create rectangle 320 [expr 110 + 150 * $i] 370 [expr 110 + 150 * $i - 100 * [llength [lsort -unique [[atomselect top "nucleic and resname [lindex $nucleicindex $i]"] get resid]]] / [llength [lsort -unique [[atomselect top "nucleic"] get resid]]]] -fill green
		$w.main create text 345 [expr 130 + 150 * $i] -text [format "%#.3f / %#d" [expr double([llength [lsort -unique [[atomselect top "nucleic and resname [lindex $nucleicindex $i]"] get resid]]]) / [llength [lsort -unique [[atomselect top "nucleic"] get resid]]]] [llength [lsort -unique [[atomselect top "nucleic and resname [lindex $nucleicindex $i]"] get resid]]]]
		$w.main create rectangle 400 [expr 110 + 150 * $i] 450 [expr 110 + 150 * $i - 100 * [llength [lsort -unique [[atomselect top "nucleic and resname [lindex $nucleicindex $i] and within 5 of (protein)"] get resid]]] / [llength [lsort -unique [[atomselect top "nucleic and within 5 of (nucleic)"] get resid]]]] -fill blue
		$w.main create text 425 [expr 130 + 150 * $i] -text [format "%#.3f / %#d" [expr double([llength [lsort -unique [[atomselect top "nucleic and resname [lindex $nucleicindex $i] and within 5 of (protein)"] get resid]]]) / [llength [lsort -unique [[atomselect top "nucleic and within 5 of (nucleic)"] get resid]]]] [llength [lsort -unique [[atomselect top "nucleic and resname [lindex $nucleicindex $i] and within 5 of (nucleic)"] get resid]]]]
		if {[llength [lsort -unique [[atomselect top "nucleic and chain ${nucleicchain} and resname [lindex $nucleicindex $i]"] get resid]]] != 0} {
			$w.main create rectangle 480 [expr 110 + 150 * $i] 530 [expr 110 + 150 * $i - 100 * [llength [lsort -unique [[atomselect top "nucleic and resname [lindex $nucleicindex $i] and within 5 of (protein)"] get resid]]] / [llength [lsort -unique [[atomselect top "nucleic and resname [lindex $nucleicindex $i]"] get resid]]]] -fill red
			$w.main create text 505 [expr 130 + 150 * $i] -text [format "%#.3f" [expr double([llength [lsort -unique [[atomselect top "nucleic and resname [lindex $nucleicindex $i] and within 5 of (protein)"] get resid]]]) / [llength [lsort -unique [[atomselect top "nucleic and resname [lindex $nucleicindex $i]"] get resid]]]]]
		} else {
			$w.main create rectangle 480 [expr 110 + 150 * $i] 530 [expr 110 + 150 * $i] -fill red
			$w.main create text 505 [expr 130 + 150 * $i] -text "N/A"
		}
		$w.main create line 380 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmin $i] 0]] 380 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmax $i] 0]] -fill red
		$w.main create line 375 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmean $i] 0]] 380 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmean $i] 0]] -fill red
		$w.main create line 375 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmin $i] 0]] 380 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmin $i] 0]] -fill red
		$w.main create line 375 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmax $i] 0]] 380 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmax $i] 0]] -fill red
		$w.main create line 460 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmin $i] 1]] 460 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmax $i] 1]] -fill red
		$w.main create line 455 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmean $i] 1]] 460 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmean $i] 1]] -fill red
		$w.main create line 455 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmin $i] 1]] 460 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmin $i] 1]] -fill red
		$w.main create line 455 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmax $i] 1]] 460 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmax $i] 1]] -fill red
		$w.main create line 540 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmin $i] 2]] 540 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmax $i] 2]] -fill red
		$w.main create line 535 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmean $i] 2]] 540 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmean $i] 2]] -fill red
		$w.main create line 535 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmin $i] 2]] 540 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmin $i] 2]] -fill red
		$w.main create line 535 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmax $i] 2]] 540 [expr 110 + 150 * $i - 100 * [lindex [lindex $nucleicmax $i] 2]] -fill red
	}
}

proc ::RPIMap::Visualize {} {
	variable w
	variable v
	variable rpimap
	
	if {[winfo exists .visualize]} {
		wm deiconify $v
		return
	}
	
	set v [toplevel ".visualize"]
	wm title $v "RNA-Protein Interface Visualization Options"
	wm resizable $v 0 0;
	
	button $v.addph -text "Add Protein-Protein H-Bonds" -command ::RPIMap::VisualizePH
	button $v.addnh -text "Add Nucleic-Nucleic H-Bonds" -command ::RPIMap::VisualizeNH
	button $v.addih -text "Add Protein-Nucleic H-Bonds" -command ::RPIMap::VisualizeIH
	button $v.delete -text "Delete Added Graphics" -command ::RPIMap::VisualizeDel
	
	button $v.default -text "Default Representation" -command ::RPIMap::VisualizeDef
	
	grid $v.addph -column 1 -row 1 -sticky ew
	grid $v.addnh -column 1 -row 2 -sticky ew
	grid $v.addih -column 1 -row 3 -sticky ew
	grid $v.delete -column 1 -row 4 -sticky ew
	grid $v.default -column 1 -row 5 -sticky ew	
}

proc ::RPIMap::VisualizePH {} {
	graphics top color 0
	set indexes4 [measure hbonds 3.0 40 [atomselect top protein]]
	if {[llength $indexes4] > 0} {
		for {set i 0} {$i < [llength [lindex $indexes4 0]]} {incr i} {
			set point1x [[atomselect top "index [lindex [lindex $indexes4 1] $i]"] get x]
			set point1y [[atomselect top "index [lindex [lindex $indexes4 1] $i]"] get y]
			set point1z [[atomselect top "index [lindex [lindex $indexes4 1] $i]"] get z]
			set point2x [[atomselect top "index [lindex [lindex $indexes4 2] $i]"] get x]
			set point2y [[atomselect top "index [lindex [lindex $indexes4 2] $i]"] get y]
			set point2z [[atomselect top "index [lindex [lindex $indexes4 2] $i]"] get z]
			graphics top line [list $point1x $point1y $point1z] [list $point2x $point2y $point2z] width 2 style dashed
		}
	}
}

proc ::RPIMap::VisualizeNH {} {
	graphics top color 2
	set indexes3 [measure hbonds 3.0 40 [atomselect top nucleic]]
	if {[llength $indexes3] > 0} {
		for {set i 0} {$i < [llength [lindex $indexes3 0]]} {incr i} {
			set point1x [[atomselect top "index [lindex [lindex $indexes3 1] $i]"] get x]
			set point1y [[atomselect top "index [lindex [lindex $indexes3 1] $i]"] get y]
			set point1z [[atomselect top "index [lindex [lindex $indexes3 1] $i]"] get z]
			set point2x [[atomselect top "index [lindex [lindex $indexes3 2] $i]"] get x]
			set point2y [[atomselect top "index [lindex [lindex $indexes3 2] $i]"] get y]
			set point2z [[atomselect top "index [lindex [lindex $indexes3 2] $i]"] get z]
			graphics top line [list $point1x $point1y $point1z] [list $point2x $point2y $point2z] width 2 style dashed
		}
	}
}

proc ::RPIMap::VisualizeIH {} {
	graphics top color 1
	set indexes1 [measure hbonds 3.0 40 [atomselect top nucleic] [atomselect top protein]]
	if {[llength $indexes1] > 0} {
		for {set i 0} {$i < [llength [lindex $indexes1 0]]} {incr i} {
			set point1x [[atomselect top "index [lindex [lindex $indexes1 1] $i]"] get x]
			set point1y [[atomselect top "index [lindex [lindex $indexes1 1] $i]"] get y]
			set point1z [[atomselect top "index [lindex [lindex $indexes1 1] $i]"] get z]
			set point2x [[atomselect top "index [lindex [lindex $indexes1 2] $i]"] get x]
			set point2y [[atomselect top "index [lindex [lindex $indexes1 2] $i]"] get y]
			set point2z [[atomselect top "index [lindex [lindex $indexes1 2] $i]"] get z]
			graphics top line [list $point1x $point1y $point1z] [list $point2x $point2y $point2z] width 2 style dashed
		}
	}
	set indexes2 [measure hbonds 3.0 40 [atomselect top protein] [atomselect top nucleic]]
	if {[llength $indexes2] > 0} {	
		for {set i 0} {$i < [llength [lindex $indexes2 0]]} {incr i} {
			set point1x [[atomselect top "index [lindex [lindex $indexes2 1] $i]"] get x]
			set point1y [[atomselect top "index [lindex [lindex $indexes2 1] $i]"] get y]
			set point1z [[atomselect top "index [lindex [lindex $indexes2 1] $i]"] get z]
			set point2x [[atomselect top "index [lindex [lindex $indexes2 2] $i]"] get x]
			set point2y [[atomselect top "index [lindex [lindex $indexes2 2] $i]"] get y]
			set point2z [[atomselect top "index [lindex [lindex $indexes2 2] $i]"] get z]
			graphics top line [list $point1x $point1y $point1z] [list $point2x $point2y $point2z] width 2 style dashed
		}
	}
}

proc ::RPIMap::VisualizeDel {} {
	if {[llength [graphics top list]] != 0} {
		graphics top delete all
	}
}

proc ::RPIMap::VisualizeDef {} {
	mol delrep all top
	mol selection "protein"
	mol representation NewCartoon
	mol color ColorId 0
	mol addrep top
	mol selection "nucleic and not backbone"
	mol representation NewCartoon
	mol color ColorId 2
	mol addrep top
	mol selection "nucleic and backbone"
	mol representation NewCartoon
	mol color ColorId 3
	mol addrep top
}

proc ::RPIMap::getclosestprotein {resid} {
	variable proteinchain
	variable nucleicchain
	
	set close_res [atomselect top "protein and chain ${proteinchain} and within 5 of (resid $resid and nucleic and chain ${nucleicchain})"]
	
	for {set i 0.1} {$i < 5.1} {set i [expr $i + 0.1]} {
		set close_res [atomselect top "protein and chain ${proteinchain} and within $i of (resid $resid and nucleic and chain ${nucleicchain})"]
		if {[$close_res num] != 0} {
			break
		}
	}
	return [lindex [lsort -unique [$close_res get resid]] 0]
}

proc ::RPIMap::getclosestnucleic {resid} {
	variable proteinchain
	variable nucleicchain

	set close_res [atomselect top "nucleic and chain ${nucleicchain} and within 5 of (resid $resid and protein and chain ${proteinchain})"]
	
	for {set i 0.1} {$i < 5.1} {set i [expr $i + 0.1]} {
		set close_res [atomselect top "nucleic and chain ${nucleicchain} and within $i of (resid $resid and protein and chain ${proteinchain})"]
		if {[$close_res num] != 0} {
			break
		}
	}
	return [lindex [lsort -unique [$close_res get resid]] 0]
}

proc ::RPIMap::scrollheight {} {
	variable res_proteins
	variable res_nucleics
	variable scroll_height
	variable optionselect
	
	if {$optionselect == {interaction}} {
		set num_proteins [lindex $::RPIMap::res_proteins end]
		set num_nucleics [lindex $::RPIMap::res_nucleics end]
		set scroll_height [expr max([expr $num_proteins - $::RPIMap::fst_proteins],[expr $num_nucleics - $::RPIMap::fst_nucleics]) * 10 + 20]
	} elseif {$optionselect == {amino}} {
		set scroll_height 500
	} elseif {$optionselect == {rna}} {
		set scroll_height 500
	} elseif {$optionselect == {statistics}} {
		set scroll_height 600
	} elseif {$optionselect == {proteinstat}} {
		set scroll_height 3000
	} elseif {$optionselect == {nucleicstat}} {
		set scroll_height 600
	} else {}
}

proc ::RPIMap::Save {} {
	variable w
	variable rpimap
	variable scroll_height
	
	package require Img
	
	$w.main configure -height $scroll_height
	set types {{"Image Files" {.jpg}}}
	set filename [tk_getSaveFile -filetypes $types -initialfile capture.jpg -defaultextension .jpg]
	if {$filename != {}} {
		set image [image create photo -format window -data $w.main]
		$image write -format png $filename
		image delete $image
	}
	$w.main configure -height 500
}

proc rpimap_tk {} {
	::RPIMap::rpimap
	return $::RPIMap::w
}
