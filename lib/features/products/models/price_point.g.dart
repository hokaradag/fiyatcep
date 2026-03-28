// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PricePointImpl _$$PricePointImplFromJson(Map<String, dynamic> json) =>
    _$PricePointImpl(
      price: (json['price'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$$PricePointImplToJson(_$PricePointImpl instance) =>
    <String, dynamic>{
      'price': instance.price,
      'date': instance.date.toIso8601String(),
    };
