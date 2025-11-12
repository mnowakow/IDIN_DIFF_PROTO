import 'package:flutter/material.dart';
import 'package:idin_diff_prototype/annotation_filter_notifier.dart';
import 'package:idin_diff_prototype/annotation_notifier.dart';
import 'package:idin_diff_prototype/helper.dart';
import 'package:idin_diff_prototype/login_page_notifier.dart';

class LoginPage extends StatefulWidget {
  final LoginPageNotifier lpNotifier;
  final GlobalKey<NavigatorState> nav;

  const LoginPage(this.lpNotifier, this.nav, {super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String username = 'admin';

  @override
  void initState() {
    super.initState();
    AnnotationNotifier.instance.deleteAnnotationsByUser("admin");
    AnnotationNotifier.instance.deleteAnnotationsByUser("default");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: Card(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            0.0,
            MediaQuery.of(context).size.height / 4,
            0.0,
            0.0,
          ),
          child: Column(
            spacing: 40.0,
            children: [
              Icon(Icons.person, size: 50.0),
              SizedBox(
                height: 50,
                width: 300,
                child: Autocomplete<String>(
                  optionsBuilder: (textEditingValue) async {
                    final options = await getAllUsers();
                    return options.where(
                      (option) => option.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      ),
                    );
                  },
                  fieldViewBuilder: (
                    context,
                    controller,
                    focusNode,
                    onEditingComplete,
                  ) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onEditingComplete: onEditingComplete,
                      decoration: InputDecoration(
                        hintText: 'Username',
                        labelText: 'admin',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          username = value;
                        });
                      },
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 300,
                          ), // gleich wie Textfeld
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                title: Text(option),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  onSelected: (String selection) {
                    setState(() {
                      username = selection;
                    });
                  },
                ),
              ),

              FloatingActionButton(
                backgroundColor: Colors.amber,
                onPressed: () {
                  setState(() {
                    widget.lpNotifier.loggedIn(username);
                    widget.nav.currentState?.pop();
                  });
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
