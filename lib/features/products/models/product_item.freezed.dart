// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProductItem _$ProductItemFromJson(Map<String, dynamic> json) {
  return _ProductItem.fromJson(json);
}

/// @nodoc
mixin _$ProductItem {
  String get id => throw _privateConstructorUsedError;
  String get marketId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get brand => throw _privateConstructorUsedError;
  String get market => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  bool get isDiscounted => throw _privateConstructorUsedError;
  List<PricePoint> get priceHistory => throw _privateConstructorUsedError;

  /// Serializes this ProductItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductItemCopyWith<ProductItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductItemCopyWith<$Res> {
  factory $ProductItemCopyWith(
    ProductItem value,
    $Res Function(ProductItem) then,
  ) = _$ProductItemCopyWithImpl<$Res, ProductItem>;
  @useResult
  $Res call({
    String id,
    String marketId,
    String name,
    String brand,
    String market,
    double price,
    bool isDiscounted,
    List<PricePoint> priceHistory,
  });
}

/// @nodoc
class _$ProductItemCopyWithImpl<$Res, $Val extends ProductItem>
    implements $ProductItemCopyWith<$Res> {
  _$ProductItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? marketId = null,
    Object? name = null,
    Object? brand = null,
    Object? market = null,
    Object? price = null,
    Object? isDiscounted = null,
    Object? priceHistory = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            marketId: null == marketId
                ? _value.marketId
                : marketId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            brand: null == brand
                ? _value.brand
                : brand // ignore: cast_nullable_to_non_nullable
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
            priceHistory: null == priceHistory
                ? _value.priceHistory
                : priceHistory // ignore: cast_nullable_to_non_nullable
                      as List<PricePoint>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductItemImplCopyWith<$Res>
    implements $ProductItemCopyWith<$Res> {
  factory _$$ProductItemImplCopyWith(
    _$ProductItemImpl value,
    $Res Function(_$ProductItemImpl) then,
  ) = __$$ProductItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String marketId,
    String name,
    String brand,
    String market,
    double price,
    bool isDiscounted,
    List<PricePoint> priceHistory,
  });
}

/// @nodoc
class __$$ProductItemImplCopyWithImpl<$Res>
    extends _$ProductItemCopyWithImpl<$Res, _$ProductItemImpl>
    implements _$$ProductItemImplCopyWith<$Res> {
  __$$ProductItemImplCopyWithImpl(
    _$ProductItemImpl _value,
    $Res Function(_$ProductItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? marketId = null,
    Object? name = null,
    Object? brand = null,
    Object? market = null,
    Object? price = null,
    Object? isDiscounted = null,
    Object? priceHistory = null,
  }) {
    return _then(
      _$ProductItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        marketId: null == marketId
            ? _value.marketId
            : marketId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        brand: null == brand
            ? _value.brand
            : brand // ignore: cast_nullable_to_non_nullable
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
        priceHistory: null == priceHistory
            ? _value._priceHistory
            : priceHistory // ignore: cast_nullable_to_non_nullable
                  as List<PricePoint>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductItemImpl extends _ProductItem {
  const _$ProductItemImpl({
    required this.id,
    required this.marketId,
    required this.name,
    required this.brand,
    required this.market,
    required this.price,
    required this.isDiscounted,
    final List<PricePoint> priceHistory = const [],
  }) : _priceHistory = priceHistory,
       super._();

  factory _$ProductItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductItemImplFromJson(json);

  @override
  final String id;
  @override
  final String marketId;
  @override
  final String name;
  @override
  final String brand;
  @override
  final String market;
  @override
  final double price;
  @override
  final bool isDiscounted;
  final List<PricePoint> _priceHistory;
  @override
  @JsonKey()
  List<PricePoint> get priceHistory {
    if (_priceHistory is EqualUnmodifiableListView) return _priceHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_priceHistory);
  }

  @override
  String toString() {
    return 'ProductItem(id: $id, marketId: $marketId, name: $name, brand: $brand, market: $market, price: $price, isDiscounted: $isDiscounted, priceHistory: $priceHistory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.marketId, marketId) ||
                other.marketId == marketId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.market, market) || other.market == market) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.isDiscounted, isDiscounted) ||
                other.isDiscounted == isDiscounted) &&
            const DeepCollectionEquality().equals(
              other._priceHistory,
              _priceHistory,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    marketId,
    name,
    brand,
    market,
    price,
    isDiscounted,
    const DeepCollectionEquality().hash(_priceHistory),
  );

  /// Create a copy of ProductItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductItemImplCopyWith<_$ProductItemImpl> get copyWith =>
      __$$ProductItemImplCopyWithImpl<_$ProductItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductItemImplToJson(this);
  }
}

abstract class _ProductItem extends ProductItem {
  const factory _ProductItem({
    required final String id,
    required final String marketId,
    required final String name,
    required final String brand,
    required final String market,
    required final double price,
    required final bool isDiscounted,
    final List<PricePoint> priceHistory,
  }) = _$ProductItemImpl;
  const _ProductItem._() : super._();

  factory _ProductItem.fromJson(Map<String, dynamic> json) =
      _$ProductItemImpl.fromJson;

  @override
  String get id;
  @override
  String get marketId;
  @override
  String get name;
  @override
  String get brand;
  @override
  String get market;
  @override
  double get price;
  @override
  bool get isDiscounted;
  @override
  List<PricePoint> get priceHistory;

  /// Create a copy of ProductItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductItemImplCopyWith<_$ProductItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
