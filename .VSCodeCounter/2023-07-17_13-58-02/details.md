# Details

Date : 2023-07-17 13:58:02

Directory c:\\Users\\nbuma\\flutter-projects\\chatbot\\lib

Total : 41 files,  1868 codes, 46 comments, 283 blanks, all 2197 lines

[Summary](results.md) / Details / [Diff Summary](diff.md) / [Diff Details](diff-details.md)

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [lib/core/error/exception.dart](/lib/core/error/exception.dart) | Dart | 6 | 0 | 2 | 8 |
| [lib/core/error/failures.dart](/lib/core/error/failures.dart) | Dart | 13 | 0 | 4 | 17 |
| [lib/data/constants.dart](/lib/data/constants.dart) | Dart | 4 | 0 | 2 | 6 |
| [lib/data/datasources/api_remote_datasource.dart](/lib/data/datasources/api_remote_datasource.dart) | Dart | 125 | 11 | 29 | 165 |
| [lib/data/datasources/firebase/auth.dart](/lib/data/datasources/firebase/auth.dart) | Dart | 35 | 0 | 7 | 42 |
| [lib/data/datasources/firebase/firestore.dart](/lib/data/datasources/firebase/firestore.dart) | Dart | 103 | 13 | 18 | 134 |
| [lib/data/models/answer_model.dart](/lib/data/models/answer_model.dart) | Dart | 13 | 0 | 4 | 17 |
| [lib/data/models/speech_model.dart](/lib/data/models/speech_model.dart) | Dart | 17 | 0 | 4 | 21 |
| [lib/data/models/transcription_model.dart](/lib/data/models/transcription_model.dart) | Dart | 15 | 0 | 4 | 19 |
| [lib/data/repositories/api_repository_impl.dart](/lib/data/repositories/api_repository_impl.dart) | Dart | 48 | 0 | 6 | 54 |
| [lib/domain/entities/answer_entity.dart](/lib/domain/entities/answer_entity.dart) | Dart | 14 | 0 | 4 | 18 |
| [lib/domain/entities/chat_message_entity.dart](/lib/domain/entities/chat_message_entity.dart) | Dart | 9 | 0 | 4 | 13 |
| [lib/domain/entities/speech_entity.dart](/lib/domain/entities/speech_entity.dart) | Dart | 22 | 0 | 6 | 28 |
| [lib/domain/entities/transcription_entity.dart](/lib/domain/entities/transcription_entity.dart) | Dart | 16 | 0 | 4 | 20 |
| [lib/domain/entities/viseme_entity.dart](/lib/domain/entities/viseme_entity.dart) | Dart | 5 | 0 | 2 | 7 |
| [lib/domain/repositories/api_repository.dart](/lib/domain/repositories/api_repository.dart) | Dart | 13 | 0 | 2 | 15 |
| [lib/domain/usecases/get_answer.dart](/lib/domain/usecases/get_answer.dart) | Dart | 13 | 0 | 4 | 17 |
| [lib/domain/usecases/get_speech.dart](/lib/domain/usecases/get_speech.dart) | Dart | 13 | 0 | 4 | 17 |
| [lib/domain/usecases/get_transcription.dart](/lib/domain/usecases/get_transcription.dart) | Dart | 11 | 0 | 4 | 15 |
| [lib/injector.dart](/lib/injector.dart) | Dart | 28 | 0 | 4 | 32 |
| [lib/main.dart](/lib/main.dart) | Dart | 33 | 1 | 4 | 38 |
| [lib/presentation/provider/block_provider.dart](/lib/presentation/provider/block_provider.dart) | Dart | 9 | 0 | 4 | 13 |
| [lib/presentation/provider/chat_provider.dart](/lib/presentation/provider/chat_provider.dart) | Dart | 79 | 0 | 17 | 96 |
| [lib/presentation/provider/gender_provider.dart](/lib/presentation/provider/gender_provider.dart) | Dart | 23 | 0 | 7 | 30 |
| [lib/presentation/provider/language_provider.dart](/lib/presentation/provider/language_provider.dart) | Dart | 23 | 0 | 7 | 30 |
| [lib/presentation/provider/model_provider.dart](/lib/presentation/provider/model_provider.dart) | Dart | 23 | 0 | 7 | 30 |
| [lib/presentation/provider/recording_provider.dart](/lib/presentation/provider/recording_provider.dart) | Dart | 9 | 0 | 4 | 13 |
| [lib/presentation/screens/home_screen/home_screen.dart](/lib/presentation/screens/home_screen/home_screen.dart) | Dart | 19 | 0 | 3 | 22 |
| [lib/presentation/screens/home_screen/widgets/drawer_widget.dart](/lib/presentation/screens/home_screen/widgets/drawer_widget.dart) | Dart | 96 | 1 | 6 | 103 |
| [lib/presentation/screens/login_register_screen/login_register_screen.dart](/lib/presentation/screens/login_register_screen/login_register_screen.dart) | Dart | 120 | 4 | 12 | 136 |
| [lib/presentation/screens/profile_screen/profile_screen.dart](/lib/presentation/screens/profile_screen/profile_screen.dart) | Dart | 31 | 0 | 6 | 37 |
| [lib/presentation/screens/settings_screen/settings_screen.dart](/lib/presentation/screens/settings_screen/settings_screen.dart) | Dart | 125 | 0 | 9 | 134 |
| [lib/presentation/screens/speech_screen/speech_screen.dart](/lib/presentation/screens/speech_screen/speech_screen.dart) | Dart | 325 | 16 | 39 | 380 |
| [lib/presentation/screens/speech_screen/widgets/chat_bubble.dart](/lib/presentation/screens/speech_screen/widgets/chat_bubble.dart) | Dart | 72 | 0 | 6 | 78 |
| [lib/presentation/screens/speech_screen/widgets/record_control_widget.dart](/lib/presentation/screens/speech_screen/widgets/record_control_widget.dart) | Dart | 84 | 0 | 5 | 89 |
| [lib/presentation/screens/speech_screen/widgets/sliding_up_panel_widget.dart](/lib/presentation/screens/speech_screen/widgets/sliding_up_panel_widget.dart) | Dart | 158 | 0 | 9 | 167 |
| [lib/presentation/screens/tree_screen/tree_screen.dart](/lib/presentation/screens/tree_screen/tree_screen.dart) | Dart | 29 | 0 | 4 | 33 |
| [lib/theme/app_bar_theme.dart](/lib/theme/app_bar_theme.dart) | Dart | 20 | 0 | 5 | 25 |
| [lib/theme/dark_theme.dart](/lib/theme/dark_theme.dart) | Dart | 15 | 0 | 2 | 17 |
| [lib/theme/light_theme.dart](/lib/theme/light_theme.dart) | Dart | 35 | 0 | 2 | 37 |
| [lib/utils/helper_widgets.dart](/lib/utils/helper_widgets.dart) | Dart | 17 | 0 | 7 | 24 |

[Summary](results.md) / Details / [Diff Summary](diff.md) / [Diff Details](diff-details.md)