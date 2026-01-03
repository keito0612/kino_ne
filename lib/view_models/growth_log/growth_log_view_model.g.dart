// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_log_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todayTotalGrowthHash() => r'70f5d9743c3f18bb0f27bdf62af16e7750e3011b';

/// 今日の合計成長量（全ツリー合計）を表示するためのシンプルProvider
///
/// Copied from [todayTotalGrowth].
@ProviderFor(todayTotalGrowth)
final todayTotalGrowthProvider = AutoDisposeFutureProvider<int>.internal(
  todayTotalGrowth,
  name: r'todayTotalGrowthProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayTotalGrowthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayTotalGrowthRef = AutoDisposeFutureProviderRef<int>;
String _$growthLogViewModelHash() =>
    r'0b38975866c234df553fce9452370464b6122125';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$GrowthLogViewModel
    extends BuildlessAutoDisposeAsyncNotifier<List<GrowthLog>> {
  late final int treeId;

  FutureOr<List<GrowthLog>> build(int treeId);
}

/// See also [GrowthLogViewModel].
@ProviderFor(GrowthLogViewModel)
const growthLogViewModelProvider = GrowthLogViewModelFamily();

/// See also [GrowthLogViewModel].
class GrowthLogViewModelFamily extends Family<AsyncValue<List<GrowthLog>>> {
  /// See also [GrowthLogViewModel].
  const GrowthLogViewModelFamily();

  /// See also [GrowthLogViewModel].
  GrowthLogViewModelProvider call(int treeId) {
    return GrowthLogViewModelProvider(treeId);
  }

  @override
  GrowthLogViewModelProvider getProviderOverride(
    covariant GrowthLogViewModelProvider provider,
  ) {
    return call(provider.treeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'growthLogViewModelProvider';
}

/// See also [GrowthLogViewModel].
class GrowthLogViewModelProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          GrowthLogViewModel,
          List<GrowthLog>
        > {
  /// See also [GrowthLogViewModel].
  GrowthLogViewModelProvider(int treeId)
    : this._internal(
        () => GrowthLogViewModel()..treeId = treeId,
        from: growthLogViewModelProvider,
        name: r'growthLogViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$growthLogViewModelHash,
        dependencies: GrowthLogViewModelFamily._dependencies,
        allTransitiveDependencies:
            GrowthLogViewModelFamily._allTransitiveDependencies,
        treeId: treeId,
      );

  GrowthLogViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.treeId,
  }) : super.internal();

  final int treeId;

  @override
  FutureOr<List<GrowthLog>> runNotifierBuild(
    covariant GrowthLogViewModel notifier,
  ) {
    return notifier.build(treeId);
  }

  @override
  Override overrideWith(GrowthLogViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: GrowthLogViewModelProvider._internal(
        () => create()..treeId = treeId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        treeId: treeId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<GrowthLogViewModel, List<GrowthLog>>
  createElement() {
    return _GrowthLogViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GrowthLogViewModelProvider && other.treeId == treeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, treeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GrowthLogViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<List<GrowthLog>> {
  /// The parameter `treeId` of this provider.
  int get treeId;
}

class _GrowthLogViewModelProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          GrowthLogViewModel,
          List<GrowthLog>
        >
    with GrowthLogViewModelRef {
  _GrowthLogViewModelProviderElement(super.provider);

  @override
  int get treeId => (origin as GrowthLogViewModelProvider).treeId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
