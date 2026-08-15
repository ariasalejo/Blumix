#!/usr/bin/env bash
blumix_network() {
    blx_title "🌐 RED"
    ip -brief address 2>/dev/null | while IFS= read -r line; do blx_row "$line"; done
    blx_row "DNS: $(grep nameserver /etc/resolv.conf 2>/dev/null | head -1 | awk '{print $2}')"
    blx_bottom
}
