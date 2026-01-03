// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pageViewModelHash() => r'79a9786bce5fd65ba7f49e9bec43c804c36cf7ab';

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

abstract class _$PageViewModel
    extends BuildlessAutoDisposeAsyncNotifier<List<Page>> {
  late final int treeId;

  FutureOr<List<Page>> build(int treeId);
}

/// See also [PageViewModel].
@ProviderFor(PageViewModel)
const pageViewModelProvider = PageViewModelFamily();

/// See also [PageViewModel].
class PageViewModelFamily extends Family<AsyncValue<List<Page>>> {
  /// See also [PageViewModel].
  const PageViewModelFamily();

  /// See also [PageViewModel].
  PageViewModelProvider call(int treeId) {
    return PageViewModelProvider(treeId);
  }

  @override
  PageViewModelProvider getProviderOverride(
    covariant PageViewModelProvider provider,
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
  String? get name => r'pageViewModelProvider';
}

/// See also [PageViewModel].
class PageViewModelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<PageViewModel, List<Page>> {
  /// See also [PageViewModel].
  PageViewModelProvider(int treeId)
    : this._internal(
        () => PageViewModel()..treeId = treeId,
        from: pageViewModelProvider,
        name: r'pageViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pageViewModelHash,
        dependencies: PageViewModelFamily._dependencies,
        allTransitiveDependencies:
            PageViewModelFamily._allTransitiveDependencies,
        treeId: treeId,
      );

  PageViewModelProvider._internal(
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
  FutureOr<List<Page>> runNotifierBuild(covariant PageViewModel notifier) {
    return notifier.build(treeId);
  }

  @override
  Override overrideWith(PageViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: PageViewModelProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<PageViewModel, List<Page>>
  createElement() {
    return _PageViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PageViewModelProvider && other.treeId == treeId;
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
mixin PageViewModelRef on AutoDisposeAsyncNotifierProviderRef<List<Page>> {
  /// The parameter `treeId` of this provider.
  int get treeId;
}

class _PageViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PageViewModel, List<Page>>
    with PageViewModelRef {
  _PageViewModelProviderElement(super.provider);

  @override
  int get treeId => (origin as PageViewModelProvider).treeId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
