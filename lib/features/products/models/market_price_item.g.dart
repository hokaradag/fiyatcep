// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_price_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MarketPriceItemImpl _$$MarketPriceItemImplFromJson(
  Map<String, dynamic> json,
) => _$MarketPriceItemImpl(
  marketId: json['marketId'] as String,
  market: json['market'] as String,
  price: (json['price'] as num).toDouble(),
  isDiscounted: json['isDiscounted'] as bool,
);

Map<String, dynamic> _$$MarketPriceItemImplToJson(
  _$MarketPriceItemImpl instance,
) => <String, dynamic>{
  'marketId': instance.marketId,
  'market': instance.market,
  'price': instance.price,
  'isDiscounted': instance.isDiscounted,
};
