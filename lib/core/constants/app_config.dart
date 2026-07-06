import 'church_config.dart';

class AppConfig {
  final bool useFirebase;
  final bool enableAiAssistant;
  final bool enableAdminPreview;
  final ChurchConfig church;

  const AppConfig({
    required this.useFirebase,
    required this.enableAiAssistant,
    required this.enableAdminPreview,
    required this.church,
  });
}

const appConfig = AppConfig(
  useFirebase: false,
  enableAiAssistant: true,
  enableAdminPreview: true,
  church: churchConfig,
);
