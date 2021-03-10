# *************************************************************************
#
# Copyright 2020 Xilinx, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# *************************************************************************
if {![info exists ip_name] || ![info exists subsystem_dir]} {
    set msg "Error: \"export_ip.tcl\" requires valid values of \"ip_name\" and \"subsystem_dir\"\n"
    append msg "- Use \"set ip_name NAME_OF_IP_MODULE\" to set which IP is to be exported\n"
    append msg "- Use \"set subsystem_dir PATH_OF_SUBSYSTEM_SRC\" to set the subsystem directory\n"
    error $msg
}

set tmp_dir /tmp

write_ip_tcl -force -no_ip_version -ip_name $ip_name [get_ips $ip_name] ${tmp_dir}/${ip_name}.tcl

set fp [open ${tmp_dir}/${ip_name}.tcl r]
set lines [split [read $fp] "\n"]
close $fp

set fp [open ${subsystem_dir}/vivado_ip/${ip_name}.tcl w]

for {set i 0} {$i < [llength $lines]} {incr i} {
    set line [lindex $lines $i]
    if {[regexp "set .* $ip_name" $line]} {
        break
    }
}

puts $fp $line
incr i
set line [lindex $lines $i]
append line { -dir ${ip_build_dir}}
puts $fp $line
incr i

for {} {$i < [llength $lines]} {incr i} {
    set line [lindex $lines $i]

    if {[string equal "" $line]} {
        continue
    }
    
    if {[string first "#" $line] == 0} {
        continue
    }

    if {[string first " " $line] == 0} {
        set line "  $line"
    }

    puts $fp $line
}

close $fp
