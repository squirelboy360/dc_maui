/// Patch types for diff
enum PatchType {
  replace,
  props,
  text,
  add,
  remove,
  componentProps,
}

/// Patch object for VDOM updates
class VDomPatch {
  final PatchType type;
  final String path;
  final dynamic payload;

  VDomPatch({
    required this.type,
    required this.path,
    this.payload,
  });
}
