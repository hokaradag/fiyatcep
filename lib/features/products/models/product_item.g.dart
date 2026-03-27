// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductItemImpl _$$ProductItemImplFromJson(Map<String, dynamic> json) =>
    _$ProductItemImpl(
      id: json['id'] as String,
      marketId: json['marketId'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      market: json['market'] as String,
      price: (json['price'] as num).toDouble(),
      isDiscounted: json['isDiscounted'] as bool,
    );

Map<String, dynamic> _$$ProductItemImplToJson(_$ProductItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'marketId': instance.marketId,
      'name': instance.name,
      'brand': instance.brand,
      'market': instance.market,
      'price': instance.price,
      'isDiscounted': instance.isDiscounted,
    };
