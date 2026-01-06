include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-immstore
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_LICENSE:=MIT
PKG_MAINTAINER:=Leeson

LUCI_TITLE:=LuCI Support for Package Manager
LUCI_DEPENDS:=
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
