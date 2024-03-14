import 'package:flutter/material.dart';
import 'package:my_family_app/constants/app_constants.dart';
import 'package:my_family_app/models/what_where.dart';
import 'package:my_family_app/screens/what_where/what_where_screen.dart';
import 'package:my_family_app/services/what_where_service.dart';
import 'package:my_family_app/utils/constants.dart';
import 'package:my_family_app/widgets/main_app_bar.dart';

class AddWhatWhereScreen extends StatefulWidget {
  const AddWhatWhereScreen({
    super.key,
    required this.updateMode,
    this.whatWhereDataToUpdate,
  });

  final bool updateMode;
  final WhatWhereData? whatWhereDataToUpdate;

  @override
  State<AddWhatWhereScreen> createState() => _AddWhatWhereScreenState();
}

class _AddWhatWhereScreenState extends State<AddWhatWhereScreen> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController whatController = TextEditingController();
  final TextEditingController whereController = TextEditingController();
  DateTime creationDate = DateTime.now();

  final FocusNode whatInputFocus = FocusNode();
  final FocusNode whereInputFocus = FocusNode();

  late WhatWhere whatWhere;

  @override
  void initState() {
    super.initState();

    if (widget.whatWhereDataToUpdate != null) {
      whatWhere = widget.whatWhereDataToUpdate!.whatWhere;

      whatController.text = whatWhere.what;
      whereController.text = whatWhere.where;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(extendBody: true,
      appBar: const MainAppBar(
        mainTitle: appTitle,
        backgroundColor: AppBarColors.whatWhere,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.updateMode ? 'Modifica' : 'Aggiungi',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const Divider(
                color: Colors.orange,
                thickness: 1,
                height: 40,
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: whatController,
                      focusNode: whatInputFocus,
                      decoration: InputDecoration(
                        label: const Text('Cosa'),
                        filled: true,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.orange[900]!,
                          ),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    TextFormField(
                      controller: whereController,
                      focusNode: whereInputFocus,
                      decoration: InputDecoration(
                        label: const Text('Dove'),
                        filled: true,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.orange[900]!,
                          ),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.orange[900],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_what_where',
        onPressed: () async {
          if (whatController.text == '') {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Warning'),
                content: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, height: 1.5),
                    children: [
                      TextSpan(
                        text: 'Non hai selezionato un oggetto!!! ',
                      ),
                      TextSpan(
                        text: 'Indica un nome',
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      FocusScope.of(context).requestFocus(whatInputFocus);
                    },
                    child: const Text(
                      'Ok, capito',
                      style: TextStyle(
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (whereController.text == '') {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Warning'),
                content: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, height: 1.5),
                    children: [
                      TextSpan(
                        text: 'Non hai selezionato un posto!!! ',
                      ),
                      TextSpan(
                        text: 'Indica dove l\'hai messo',
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      FocusScope.of(context).requestFocus(whereInputFocus);
                    },
                    child: const Text(
                      'Ok, capito',
                      style: TextStyle(
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            WhatWhere newWhatWhere = WhatWhere(
                what: whatController.text,
                where: whereController.text,
                when: DateTime.now());

            DatabaseCallStatus callStatus;

            if (widget.updateMode) {
              WhatWhereData updatedWhatWhere = WhatWhereData(
                  key: widget.whatWhereDataToUpdate!.key,
                  whatWhere: newWhatWhere);
              callStatus =
                  await updateWhatWhere(newWhatwhereData: updatedWhatWhere);
            } else {
              callStatus = await createWhatWhere(newWhatWhere: newWhatWhere);
            }

            if (callStatus == DatabaseCallStatus.error) {
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Warning'),
                    content:
                        const Text('Qualcosa è andato storto con il database.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Ok, capito'),
                      ),
                    ],
                  ),
                );
              }
            } else {
              if (mounted) {
                await Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WhatWhereScreen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              }
            }
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(36),
        ),
        backgroundColor: Colors.orange,
        elevation: 12,
        label: const Text(
          'Salva',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    whatController.dispose();
    whereController.dispose();
    whatInputFocus.dispose();
    whereInputFocus.dispose();

    super.dispose();
  }
}
