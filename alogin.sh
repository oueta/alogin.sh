#!/usr/bin/expect -f
if {[llength $argv] < 1} {
    puts "Usage: ./alogin.sh host template";
    exit 1;
}
set host_arg [lindex $argv 0]
set config_file [open "[file dirname [file normalize [info script]]]/alogin.conf"]
set config_items [split [read $config_file] "\n"]
close $config_file
set host_index -1
set found_hosts 0
set ambiguous_hosts ""
set i -1
proc setFoundHosts {i h} {
    upvar host_index index
    upvar found_hosts hosts
    set index $i
    set hosts $h
}
# search for template by template
if {[llength $argv] == 2} {
    set template_arg [lindex $argv 1]
    foreach config_item $config_items {
        incr i
        set host_tpl [lindex [split [string trim $config_item] ":"] 0]
        if {($host_tpl == $template_arg)} {
            setFoundHosts $i 1
            break;
        }
    }
    if {$found_hosts == 0} {
        puts "Template not found"
        exit 1
    }
} else {
        foreach config_item $config_items {
            incr i
            set host_tpl [lindex [split [string trim $config_item] ":"] 0]
            if {($host_tpl != "") && ([string match "*$host_tpl*" $host_arg])} {
                if {$host_tpl == $host_arg} {
                    # match exact
                    setFoundHosts $i 1
                    break;
                } else {
                    # match *host_tpl* in host_arg (example: host_tpl = mail, host_arg = mail.remote-host.com)
                    setFoundHosts $i [incr found_hosts]
                    append ambiguous_hosts "\"$host_tpl\" "
                }
            }
        }
}
# execute template
if {$host_index > -1} {
        if { $found_hosts == 1 } {
            set host_config [split [string trim [lindex $config_items $host_index]] ":"]
            set host_tpl [lindex $host_config 0]
            set proto [lindex $host_config 1]
            set port [lindex $host_config 2]
            set user [lindex $host_config 3]
            set passwd [lindex $host_config 4]
            if {$passwd == "\$"} {
                set env_tpl [string toupper $host_tpl]
                if {[array names env $env_tpl] != ""} {
                    set passwd $env($env_tpl)
                } else {
                        puts "Environment variable \$$env_tpl not found"
                        exit 1
                }
            }
            switch $proto {
                        "ssh" {
                                puts "Connecting $host_arg via SSH using \"$host_tpl\" template"
                                spawn ssh $user@$host_arg -p $port
                                expect {
                                    "yes/no*" {
                                        send "yes\n"
                                        exp_continue
                                    }
                                    "?assword*" {
                                        send "$passwd\n"
                                        interact
                                        exit 0;
                                    }
                                }
                         }
                         "telnet" {
                                    puts "Connecting $host_arg via telnet using \"$host_tpl\" template"
                                    spawn telnet -l $user $host_arg $port
                                    expect {
                                            "?ser*" {
                                                send "$user\n"
                                                exp_continue
                                            }
                                            "?assword*" {
                                                send "$passwd\n"
                                                interact
                                                exit 0;
                                            }
                                    }
                         }
            }
       } else { puts "Ambiguous hosts $ambiguous_hosts" }
} else { puts "Host not found" }
exit 1;
