import 'package:flutter/material.dart';
import 'package:my_family_app/constants/app_constants.dart';
import 'package:my_family_app/extensions/date_time_x.dart';
import 'package:my_family_app/models/freezer_item.dart';
import 'package:my_family_app/screens/freezer_item/freezer_screen.dart';
import 'package:my_family_app/services/frerezer_item_service.dart';
import 'package:my_family_app/utils/constants.dart';
import 'package:my_family_app/widgets/main_app_bar.dart';

class AddFreezerScreen extends StatefulWidget {
  const AddFreezerScreen({
    super.key,
    required this.updateMode,
    this.freezerItemDataToUpdate,
  });

  final bool updateMode;
  final FreezerItemData? freezerItemDataToUpdate;

  @override
  State<AddFreezerScreen> createState() => _AddFreezerScreenState();
}

class _AddFreezerScreenState extends State<AddFreezerScreen> {
  final formKey = GlobalKey<FormState>();
  DateTime selectedExpiringDate = DateTime.now();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController expiringDateController = TextEditingController();

  final FocusNode nameInputFocus = FocusNode();
  final FocusNode expiringDateInputFocus = FocusNode();

  late FreezerItem freezerItem;

  @override
  void initState() {
    super.initState();

    if (widget.freezerItemDataToUpdate != null) {
      freezerItem = widget.freezerItemDataToUpdate!.freezerItem;

      nameController.text = freezerItem.name;
      quantityController.text = freezerItem.quantity;
      expiringDateController.text =
          freezerItem.expirationDate.formatToTextInput();
      selectedExpiringDate = freezerItem.expirationDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const MainAppBar(
        mainTitle: appTitle,
        backgroundColor: AppBarColors.freezer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.updateMode ? 'Modifica' : 'Aggiungi'} un prodotto',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const Divider(
                color: Colors.cyan,
                thickness: 1,
                height: 32,
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      focusNode: nameInputFocus,
                      decoration: const InputDecoration(
                        label: Text('Nome'),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextFormField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                        label: Text('Quantità'),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextFormField(
                      controller: expiringDateController,
                      focusNode: expiringDateInputFocus,
                      decoration: const InputDecoration(
                        label: Text('Seleziona la data di scadenza'),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedExpiringDate,
                          firstDate: DateTime(1950),
                          lastDate: DateTime(2101),
                        );

                        if (pickedDate != null) {
                          expiringDateController.text =
                              pickedDate.formatToTextInput();
                          selectedExpiringDate = pickedDate;
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_freezer_item',
        onPressed: () async {
          if (nameController.text == '') {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Warning'),
                content: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, height: 1.5),
                    children: [
                      TextSpan(
                        text: 'Non hai selezionato un nome!!! ',
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
                      FocusScope.of(context).requestFocus(nameInputFocus);
                    },
                    child: const Text(
                      'Ok, capito',
                      style: TextStyle(
                        color: Colors.cyan,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (selectedExpiringDate.compareTo(DateTime.now()) <= 0) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Warning'),
                content: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, height: 1.5),
                    children: [
                      TextSpan(
                        text: 'Stai mettendo un prodotto scaduto!!! ',
                      ),
                      TextSpan(
                        text: 'Controlla bene o indica una data futura',
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      FocusScope.of(context)
                          .requestFocus(expiringDateInputFocus);
                    },
                    child: const Text(
                      'Ok, capito',
                      style: TextStyle(
                        color: Colors.cyan,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            FreezerItem newFreezerItem = FreezerItem(
                name: nameController.text,
                quantity: quantityController.text,
                frostingDate:
                    widget.updateMode == true ? freezerItem.frostingDate : null,
                expirationDate: DateTime(
                  selectedExpiringDate.year,
                  selectedExpiringDate.month,
                  selectedExpiringDate.day,
                ));

            DatabaseCallStatus callStatus;

            if (widget.updateMode) {
              FreezerItemData updatedFreezerItem = FreezerItemData(
                  key: widget.freezerItemDataToUpdate!.key,
                  freezerItem: newFreezerItem);
              callStatus =
                  await updateFreezerItem(newFreezerItem: updatedFreezerItem);
            } else {
              callStatus =
                  await createFreezerItem(newFreezerItem: newFreezerItem);
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
                    builder: (context) => const FreezerScreen(),
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
        backgroundColor: Colors.cyan,
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
    nameController.dispose();
    quantityController.dispose();
    expiringDateController.dispose();
    nameInputFocus.dispose();
    expiringDateInputFocus.dispose();

    super.dispose();
  }
}
