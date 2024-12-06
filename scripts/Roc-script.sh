# 修改默认IP & 固件名称
sed -i 's/192.168.1.1/192.168.3.18/g' package/base-files/files/bin/config_generate
sed -i "s/hostname='.*'/hostname='JDCAX1800'/g" package/base-files/files/bin/config_generate

# 修改亚瑟运行LED为绿色
# sed -i 's/&status_blue/\&status_green/g' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6000-re-ss-01.dts

# 修改太乙启动LED为绿色，运行LED为蓝色(VIKINGYFY项目)
# sed -i 's/boot/roc/g; s/running/boot/g; s/roc/running/g' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6010-re-cs-07.dts

# 移除要替换的包
rm -rf feeds/packages/net/alist
rm -rf feeds/luci/applications/luci-app-alist
rm -rf feeds/packages/net/adguardhome
rm -rf feeds/packages/net/ariang
rm -rf package/emortal/luci-app-athena-led

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# Alist & AdGuardHome & 集客无线AC控制器 & Lucky & AriaNg & 雅典娜LED控制
git clone https://github.com/sirpdboy/luci-app-partexp.git package/luci-app-partexp
git clone https://github.com/gngpp/luci-app-watchcat-plus.git package/luci-app-watchcat-plus
git clone --depth=1 https://github.com/sbwml/luci-app-alist package/luci-app-alist
git_sparse_clone main https://github.com/kenzok8/small-package adguardhome luci-app-adguardhome
git_sparse_clone main https://github.com/VIKINGYFY/packages luci-app-wolplus
git_sparse_clone master https://github.com/immortalwrt/packages net/ariang 
git clone --depth=1 https://github.com/lwb1978/openwrt-gecoosac package/openwrt-gecoosac
git clone --depth=1 https://github.com/gdy666/luci-app-lucky package/lucky
git clone https://github.com/zzsj0928/luci-app-pushbot package/luci-app-pushbot
git clone --depth=1 https://github.com/NONGFAH/luci-app-athena-led package/luci-app-athena-led
chmod +x package/luci-app-athena-led/root/etc/init.d/athena_led
chmod +x package/luci-app-athena-led/root/usr/sbin/athena-led
rm -rf package/luci-app-athena-led/luasrc/view/athena_led/athena_led_gift.htm
sed -i '/entry({ "admin", "system", "athena_led", "gift" }, template("athena_led\/athena_led_gift"), _("Gift"), 2)/d' package/luci-app-athena-led/luasrc/controller/athena_led.lua

./scripts/feeds update -a
./scripts/feeds install -a
