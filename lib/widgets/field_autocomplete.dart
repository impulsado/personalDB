import 'package:flutter/material.dart';

class FieldAutocomplete extends StatefulWidget {
  final String label;
  final String initialValue;
  final Function(String) onSelected;
  final Future<List<String>> Function() loadItemsFunction;

  const FieldAutocomplete({
    Key? key,
    required this.label,
    required this.initialValue,
    required this.onSelected,
    required this.loadItemsFunction,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FieldAutocompleteState createState() => _FieldAutocompleteState();
}

class _FieldAutocompleteState extends State<FieldAutocomplete> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _textFormFieldKey = GlobalKey();
  List<String> _items = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue;
    _loadItems();
    _controller.addListener(() {
      widget.onSelected(_controller.text);
    });
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _updateOverlay(_items);
      } else {
        if (_overlayEntry != null) {
          _overlayEntry!.remove();
          _overlayEntry = null;
        }
      }
    });
  }

  _loadItems() async {
    List<String> items = await widget.loadItemsFunction();
    setState(() {
      _items = items;
    });
  }

  void _updateOverlay(List<String> suggestions) {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    if (suggestions.isNotEmpty) {
      final RenderBox renderBox = _textFormFieldKey.currentContext!.findRenderObject() as RenderBox;
      final size = renderBox.size;

      _overlayEntry = OverlayEntry(
        builder: (BuildContext context) {
          return Positioned(
            width: size.width + 10,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0.0, 50.0),
              child: Material(
                elevation: 4.0,
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: suggestions.map<Widget>((String suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                      onTap: () {
                        _controller.text = suggestion;
                        widget.onSelected(suggestion);
                        _overlayEntry!.remove();
                        _overlayEntry = null;
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      );

      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: const TextStyle(color: Colors.black, fontSize: 16)),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 50.0,
            ),
            child: GestureDetector(
              onTap: () => _updateOverlay(_items),
              child: CompositedTransformTarget(
                link: _layerLink,
                child: Container(
                  margin: const EdgeInsets.only(top: 8.0),
                  padding: const EdgeInsets.only(left: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    key: _textFormFieldKey,
                    focusNode: _focusNode,
                    autofocus: false,
                    cursorColor: Colors.grey,
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Enter ${widget.label.toLowerCase()} here.",
                      hintStyle: const TextStyle(color: Colors.grey),
                      focusedErrorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 0),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 0),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 0),
                      ),
                    ),
                    textAlignVertical: TextAlignVertical.center,
                    onChanged: (String value) {
                      final suggestions = _items.where((String item) {
                        return item.toLowerCase().contains(value.toLowerCase());
                      }).toList();

                      _updateOverlay(suggestions);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}