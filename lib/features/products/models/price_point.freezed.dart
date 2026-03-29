// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PricePoint _$PricePointFromJson(Map<String, dynamic> json) {
  return _PricePoint.fromJson(json);
}

/// @nodoc
mixin _$PricePoint {
  double get price => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;

  /// Serializes this PricePoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PricePoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PricePointCopyWith<PricePoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PricePointCopyWith<$Res> {
  factory $PricePointCopyWith(
    PricePoint value,
    $Res Function(PricePoint) then,
  ) = _$PricePointCopyWithImpl<$Res, PricePoint>;
  @useResult
  $Res call({double price, DateTime date});
}

/// @nodoc
class _$PricePointCopyWithImpl<$Res, $Val extends PricePoint>
    implements $PricePointCopyWith<$Res> {
  _$PricePointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PricePoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? price = null, Object? date = null}) {
    return _then(
      _value.copyWith(
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PricePointImplCopyWith<$Res>
    implements $PricePointCopyWith<$Res> {
  factory _$$PricePointImplCopyWith(
    _$PricePointImpl value,
    $Res Function(_$PricePointImpl) then,
  ) = __$$PricePointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double price, DateTime date});
}

/// @nodoc
class __$$PricePointImplCopyWithImpl<$Res>
    extends _$PricePointCopyWithImpl<$Res, _$PricePointImpl>
    implements _$$PricePointImplCopyWith<$Res> {
  __$$PricePointImplCopyWithImpl(
    _$PricePointImpl _value,
    $Res Function(_$PricePointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PricePoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? price = null, Object? date = null}) {
    return _then(
      _$PricePointImpl(
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PricePointImpl extends _PricePoint {
  const _$PricePointImpl({required this.price, required this.date}) : super._();

  factory _$PricePointImpl.fromJson(Map<String, dynamic> json) =>
      _$$PricePointImplFromJson(json);

  @override
  final double price;
  @override
  final DateTime date;

  @override
  String toString() {
    return 'PricePoint(price: $price, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PricePointImpl &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.date, date) || other.date == date));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, price, date);

  /// Create a copy of PricePoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PricePointImplCopyWith<_$PricePointImpl> get copyWith =>
      __$$PricePointImplCopyWithImpl<_$PricePointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PricePointImplToJson(this);
  }
}

abstract class _PricePoint extends PricePoint {
  const factory _PricePoint({
    required final double price,
    required final DateTime date,
  }) = _$PricePointImpl;
  const _PricePoint._() : super._();

  factory _PricePoint.fromJson(Map<String, dynamic> json) =
      _$PricePointImpl.fromJson;

  @override
  double get price;
  @override
  DateTime get date;

  /// Create a copy of PricePoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PricePointImplCopyWith<_$PricePointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
