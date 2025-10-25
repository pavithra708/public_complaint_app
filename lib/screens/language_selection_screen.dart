import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: LanguageService.supportedLocales.length,
        itemBuilder: (context, index) {
          final locale = LanguageService.supportedLocales[index];
          final isSelected = languageService.currentLocale.languageCode == locale.languageCode;
          
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey[300],
                child: Text(
                  locale.languageCode.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                LanguageService.languageNames[locale.languageCode] ?? locale.languageCode,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(_getLanguageDescription(locale.languageCode)),
              trailing: isSelected 
                  ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                  : const Icon(Icons.radio_button_unchecked),
              onTap: () async {
                await languageService.changeLanguage(locale);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language changed to ${LanguageService.languageNames[locale.languageCode]}'),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
  
  String _getLanguageDescription(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English - Default language';
      case 'hi':
        return 'हिंदी - भारत की राष्ट्रीय भाषा';
      case 'es':
        return 'Español - Idioma español';
      case 'fr':
        return 'Français - Langue française';
      case 'ar':
        return 'العربية - اللغة العربية';
      default:
        return 'Language description';
    }
  }
}
