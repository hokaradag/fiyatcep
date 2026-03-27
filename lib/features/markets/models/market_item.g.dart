// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MarketItemImpl _$$MarketItemImplFromJson(Map<String, dynamic> json) =>
    _$MarketItemImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      branchCount: (json['branchCount'] as num).toInt(),
      activeDiscountCount: (json['activeDiscountCount'] as num).toInt(),
      supportsOnlineOrder: json['supportsOnlineOrder'] as bool,
      hasLoyaltyProgram: json['hasLoyaltyProgram'] as bool,
    );

Map<String, dynamic> _$$MarketItemImplToJson(_$MarketItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'branchCount': instance.branchCount,
      'activeDiscountCount': instance.activeDiscountCount,
      'supportsOnlineOrder': instance.supportsOnlineOrder,
      'hasLoyaltyProgram': instance.hasLoyaltyProgram,
    };
