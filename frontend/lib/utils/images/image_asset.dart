enum AssetType { network, local, storage }

class Asset {
  Asset({required this.url, required this.type});
  final AssetType type;
  final String url;
}

class NetworkAsset extends Asset {
  NetworkAsset({required super.url}) : super(type: AssetType.network);
}

// assets shipped with the app build
class LocalAsset extends Asset {
  LocalAsset({required super.url})
    : assert(url != ''),
      super(type: AssetType.local);
}

// stuff stored on the device's storage
class StorageAsset extends Asset {
  StorageAsset({required super.url})
    : assert(url != ''),
      super(type: AssetType.storage);
}
