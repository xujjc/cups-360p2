#!/bin/sh

# 启用 CUPS 共享
uci set cupsd.cupsd='cupsd'
uci set cupsd.cupsd.SharePrinters='yes'
uci set cupsd.cupsd.Listen='*:631'
uci commit cupsd

# 添加防火墙规则
uci add firewall rule
uci set firewall.@rule[-1].name='Allow-IPP'
uci set firewall.@rule[-1].src='lan'
uci set firewall.@rule[-1].proto='tcp'
uci set firewall.@rule[-1].dest_port='631'
uci set firewall.@rule[-1].target='ACCEPT'
uci commit firewall

# 设置 Avahi 打印机发现
cat > /etc/avahi/services/ipp.service << EOF
<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
  <name replace-wildcards="yes">%h Printer</name>
  <service>
    <type>_ipp._tcp</type>
    <subtype>_universal._sub._ipp._tcp</subtype>
    <port>631</port>
    <txt-record>txtvers=1</txt-record>
    <txt-record>qtotal=1</txt-record>
    <txt-record>rp=printers/Canon_MF4452</txt-record>
    <txt-record>note=Canon MF4452 on OpenWrt</txt-record>
    <txt-record>product=(GPL Ghostscript)</txt-record>
    <txt-record>printer-state=3</txt-record>
    <txt-record>printer-type=0x801046</txt-record>
    <txt-record>pdl=application/octet-stream,application/pdf,application/postscript,image/jpeg,image/png,image/urf</txt-record>
    <txt-record>URF=W8,SRGB24,CP1,RS600</txt-record>
  </service>
</service-group>
EOF

# 重启服务
/etc/init.d/cupsd restart
/etc/init.d/firewall restart
/etc/init.d/avahi-daemon restart

echo "打印机服务器配置完成！"
