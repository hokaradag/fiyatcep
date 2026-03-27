// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'market_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MarketItem _$MarketItemFromJson(Map<String, dynamic> json) {
  return _MarketItem.fromJson(json);
}

/// @nodoc
mixin _$MarketItem {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get branchCount => throw _privateConstructorUsedError;
  int get activeDiscountCount => throw _privateConstructorUsedError;
  bool get supportsOnlineOrder => throw _privateConstructorUsedError;
  bool get hasLoyaltyProgram => throw _privateConstructorUsedError;

  /// Serializes this MarketItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MarketItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarketItemCopyWith<MarketItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketItemCopyWith<$Res> {
  factory $MarketItemCopyWith(
    MarketItem value,
    $Res Function(MarketItem) then,
  ) = _$MarketItemCopyWithImpl<$Res, MarketItem>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    int branchCount,
    int activeDiscountCount,
    bool supportsOnlineOrder,
    bool hasLoyaltyProgram,
  });
}

/// @nodoc
class _$MarketItemCopyWithImpl<$Res, $Val extends MarketItem>
    implements $MarketItemCopyWith<$Res> {
  _$MarketItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? branchCount = null,
    Object? activeDiscountCount = null,
    Object? supportsOnlineOrder = null,
    Object? hasLoyaltyProgram = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            branchCount: null == branchCount
                ? _value.branchCount
                : branchCount // ignore: cast_nullable_to_non_nullable
                      as int,
            activeDiscountCount: null == activeDiscountCount
                ? _value.activeDiscountCount
                : activeDiscountCount // ignore: cast_nullable_to_non_nullable
                      as int,
            supportsOnlineOrder: null == supportsOnlineOrder
                ? _value.supportsOnlineOrder
                : supportsOnlineOrder // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasLoyaltyProgram: null == hasLoyaltyProgram
                ? _value.hasLoyaltyProgram
                : hasLoyaltyProgram // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MarketItemImplCopyWith<$Res>
    implements $MarketItemCopyWith<$Res> {
  factory _$$MarketItemImplCopyWith(
    _$MarketItemImpl value,
    $Res Function(_$MarketItemImpl) then,
  ) = __$$MarketItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    int branchCount,
    int activeDiscountCount,
    bool supportsOnlineOrder,
    bool hasLoyaltyProgram,
  });
}

/// @nodoc
class __$$MarketItemImplCopyWithImpl<$Res>
    extends _$MarketItemCopyWithImpl<$Res, _$MarketItemImpl>
    implements _$$MarketItemImplCopyWith<$Res> {
  __$$MarketItemImplCopyWithImpl(
    _$MarketItemImpl _value,
    $Res Function(_$MarketItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MarketItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? branchCount = null,
    Object? activeDiscountCount = null,
    Object? supportsOnlineOrder = null,
    Object? hasLoyaltyProgram = null,
  }) {
    return _then(
      _$MarketItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        branchCount: null == branchCount
            ? _value.branchCount
            : branchCount // ignore: cast_nullable_to_non_nullable
                  as int,
        activeDiscountCount: null == activeDiscountCount
            ? _value.activeDiscountCount
            : activeDiscountCount // ignore: cast_nullable_to_non_nullable
                  as int,
        supportsOnlineOrder: null == supportsOnlineOrder
            ? _value.supportsOnlineOrder
            : supportsOnlineOrder // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasLoyaltyProgram: null == hasLoyaltyProgram
            ? _value.hasLoyaltyProgram
            : hasLoyaltyProgram // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MarketItemImpl implements _MarketItem {
  const _$MarketItemImpl({
    required this.id,
    required this.name,
    required this.description,
    required this.branchCount,
    required this.activeDiscountCount,
    required this.supportsOnlineOrder,
    required this.hasLoyaltyProgram,
  });

  factory _$MarketItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarketItemImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final int branchCount;
  @override
  final int activeDiscountCount;
  @override
  final bool supportsOnlineOrder;
  @override
  final bool hasLoyaltyProgram;

  @override
  String toString() {
    return 'MarketItem(id: $id, name: $name, description: $description, branchCount: $branchCount, activeDiscountCount: $activeDiscountCount, supportsOnlineOrder: $supportsOnlineOrder, hasLoyaltyProgram: $hasLoyaltyProgram)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.branchCount, branchCount) ||
                other.branchCount == branchCount) &&
            (identical(other.activeDiscountCount, activeDiscountCount) ||
                other.activeDiscountCount == activeDiscountCount) &&
            (identical(other.supportsOnlineOrder, supportsOnlineOrder) ||
                other.supportsOnlineOrder == supportsOnlineOrder) &&
            (identical(other.hasLoyaltyProgram, hasLoyaltyProgram) ||
                other.hasLoyaltyProgram == hasLoyaltyProgram));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    branchCount,
    activeDiscountCount,
    supportsOnlineOrder,
    hasLoyaltyProgram,
  );

  /// Create a copy of MarketItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketItemImplCopyWith<_$MarketItemImpl> get copyWith =>
      __$$MarketItemImplCopyWithImpl<_$MarketItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MarketItemImplToJson(this);
  }
}

abstract class _MarketItem implements MarketItem {
  const factory _MarketItem({
    required final String id,
    required final String name,
    required final String description,
    required final int branchCount,
    required final int activeDiscountCount,
    required final bool supportsOnlineOrder,
    required final bool hasLoyaltyProgram,
  }) = _$MarketItemImpl;

  factory _MarketItem.fromJson(Map<String, dynamic> json) =
      _$MarketItemImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  int get branchCount;
  @override
  int get activeDiscountCount;
  @override
  bool get supportsOnlineOrder;
  @override
  bool get hasLoyaltyProgram;

  /// Create a copy of MarketItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketItemImplCopyWith<_$MarketItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
