// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'market_price_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MarketPriceItem _$MarketPriceItemFromJson(Map<String, dynamic> json) {
  return _MarketPriceItem.fromJson(json);
}

/// @nodoc
mixin _$MarketPriceItem {
  String get marketId => throw _privateConstructorUsedError;
  String get market => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  bool get isDiscounted => throw _privateConstructorUsedError;

  /// Serializes this MarketPriceItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MarketPriceItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarketPriceItemCopyWith<MarketPriceItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketPriceItemCopyWith<$Res> {
  factory $MarketPriceItemCopyWith(
    MarketPriceItem value,
    $Res Function(MarketPriceItem) then,
  ) = _$MarketPriceItemCopyWithImpl<$Res, MarketPriceItem>;
  @useResult
  $Res call({String marketId, String market, double price, bool isDiscounted});
}

/// @nodoc
class _$MarketPriceItemCopyWithImpl<$Res, $Val extends MarketPriceItem>
    implements $MarketPriceItemCopyWith<$Res> {
  _$MarketPriceItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketPriceItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? marketId = null,
    Object? market = null,
    Object? price = null,
    Object? isDiscounted = null,
  }) {
    return _then(
      _value.copyWith(
            marketId: null == marketId
                ? _value.marketId
                : marketId // ignore: cast_nullable_to_non_nullable
                      as String,
            market: null == market
                ? _value.market
                : market // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            isDiscounted: null == isDiscounted
                ? _value.isDiscounted
                : isDiscounted // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MarketPriceItemImplCopyWith<$Res>
    implements $MarketPriceItemCopyWith<$Res> {
  factory _$$MarketPriceItemImplCopyWith(
    _$MarketPriceItemImpl value,
    $Res Function(_$MarketPriceItemImpl) then,
  ) = __$$MarketPriceItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String marketId, String market, double price, bool isDiscounted});
}

/// @nodoc
class __$$MarketPriceItemImplCopyWithImpl<$Res>
    extends _$MarketPriceItemCopyWithImpl<$Res, _$MarketPriceItemImpl>
    implements _$$MarketPriceItemImplCopyWith<$Res> {
  __$$MarketPriceItemImplCopyWithImpl(
    _$MarketPriceItemImpl _value,
    $Res Function(_$MarketPriceItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MarketPriceItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? marketId = null,
    Object? market = null,
    Object? price = null,
    Object? isDiscounted = null,
  }) {
    return _then(
      _$MarketPriceItemImpl(
        marketId: null == marketId
            ? _value.marketId
            : marketId // ignore: cast_nullable_to_non_nullable
                  as String,
        market: null == market
            ? _value.market
            : market // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        isDiscounted: null == isDiscounted
            ? _value.isDiscounted
            : isDiscounted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MarketPriceItemImpl implements _MarketPriceItem {
  const _$MarketPriceItemImpl({
    required this.marketId,
    required this.market,
    required this.price,
    required this.isDiscounted,
  });

  factory _$MarketPriceItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarketPriceItemImplFromJson(json);

  @override
  final String marketId;
  @override
  final String market;
  @override
  final double price;
  @override
  final bool isDiscounted;

  @override
  String toString() {
    return 'MarketPriceItem(marketId: $marketId, market: $market, price: $price, isDiscounted: $isDiscounted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketPriceItemImpl &&
            (identical(other.marketId, marketId) ||
                other.marketId == marketId) &&
            (identical(other.market, market) || other.market == market) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.isDiscounted, isDiscounted) ||
                other.isDiscounted == isDiscounted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, marketId, market, price, isDiscounted);

  /// Create a copy of MarketPriceItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketPriceItemImplCopyWith<_$MarketPriceItemImpl> get copyWith =>
      __$$MarketPriceItemImplCopyWithImpl<_$MarketPriceItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MarketPriceItemImplToJson(this);
  }
}

abstract class _MarketPriceItem implements MarketPriceItem {
  const factory _MarketPriceItem({
    required final String marketId,
    required final String market,
    required final double price,
    required final bool isDiscounted,
  }) = _$MarketPriceItemImpl;

  factory _MarketPriceItem.fromJson(Map<String, dynamic> json) =
      _$MarketPriceItemImpl.fromJson;

  @override
  String get marketId;
  @override
  String get market;
  @override
  double get price;
  @override
  bool get isDiscounted;

  /// Create a copy of MarketPriceItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketPriceItemImplCopyWith<_$MarketPriceItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
