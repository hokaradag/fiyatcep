import 'package:flutter/material.dart';

class MarketBrand {
  final Color primaryColor;
  final String? logoAsset;
  final String? bannerAsset;
  const MarketBrand({
    required this.primaryColor,
    this.logoAsset,
    this.bannerAsset,
  });
}

const Map<String, MarketBrand> marketBrands = {
  'migros': MarketBrand(primaryColor: Color(0xFF004A97)),
  'a101': MarketBrand(primaryColor: Color(0xFFE30613)),
  'bim': MarketBrand(primaryColor: Color(0xFF003DA5)),
  'carrefoursa': MarketBrand(primaryColor: Color(0xFF004B99)),
  'sok': MarketBrand(primaryColor: Color(0xFFE2001A)),
  'tarim-kredi': MarketBrand(primaryColor: Color(0xFF007A33)),
  'file-market': MarketBrand(primaryColor: Color(0xFFF58220)),
};
