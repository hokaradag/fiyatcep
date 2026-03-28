// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discount_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiscountItemImpl _$$DiscountItemImplFromJson(Map<String, dynamic> json) =>
    _$DiscountItemImpl(
      id: json['id'] as String,
      productId: json['productId'] as String,
      marketId: json['marketId'] as String,
      productName: json['productName'] as String,
      marketName: json['marketName'] as String,
      oldPrice: (json['oldPrice'] as num).toDouble(),
      newPrice: (json['newPrice'] as num).toDouble(),
      validUntil: DateTime.parse(json['validUntil'] as String),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$DiscountItemImplToJson(_$DiscountItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'marketId': instance.marketId,
      'productName': instance.productName,
      'marketName': instance.marketName,
      'oldPrice': instance.oldPrice,
      'newPrice': instance.newPrice,
      'validUntil': instance.validUntil.toIso8601String(),
      'note': instance.note,
    };
