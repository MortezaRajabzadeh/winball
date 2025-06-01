import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:user_repository/user_repository.dart';
import 'package:winball_admin_panel/configs/configs.dart';
import 'package:winball_admin_panel/extensions/extensions.dart';
import 'package:winball_admin_panel/screens/screens.dart';
import 'package:winball_admin_panel/screens/users_details_screen/users_details_screen.dart';
import 'package:winball_admin_panel/screens/user_bets_screen/user_bets_screen.dart';
import 'package:winball_admin_panel/screens/transactions_list_screen/transactions_list_screen.dart';
import 'package:winball_admin_panel/widgets/global/custom_space_widget.dart';
import 'package:winball_admin_panel/widgets/global/loading_widget.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  late final TextEditingController usernameTextEditingController;
  late final ValueNotifier<List<UserModel>> listOfUsersValueNotifier;
  late final ValueNotifier<bool> isLoadingValueNotifier;
  late final UserRepositoryFunctions userRepositoryFunctions;
  late final ScrollController listOfUsersScrollController;
  bool hasMoreUsersToLoad = true;
  int page = 1;
  void initializeDatas() {
    usernameTextEditingController = TextEditingController();
    usernameTextEditingController
        .addListener(usernameTextEditingControllerListener);
    listOfUsersScrollController = ScrollController();
    listOfUsersScrollController
        .addListener(listOfUsersScrollControllerListener);
    listOfUsersValueNotifier = ValueNotifier<List<UserModel>>([]);
    isLoadingValueNotifier = ValueNotifier<bool>(false);
    userRepositoryFunctions = const UserRepositoryFunctions();
    loadListOfUsers();
  }

  Future<void> searchIntoUsersByUsername({required String username}) async {
    page = 1;
    changeIsLoadingValueNotifier(
      isLoading: true,
    );
    try {
      final UserModel user = await userRepositoryFunctions.getUserWithUsername(
        username: username,
        token: context.readAppBloc.state.currentUser.token ?? '',
      );
      changeListOfUsersValueNotifier(users: [user]);
    } catch (e) {
      if (context.mounted) {
        if (e is BaseExceptions) {
          if (e.error.toLowerCase() == AppTexts.userNotFound.toLowerCase()) {
            changeListOfUsersValueNotifier(users: []);
          } else {
            context.readAppBloc.addError(e);
          }
        }
      }
    }
    changeIsLoadingValueNotifier(
      isLoading: false,
    );
  }

  void usernameTextEditingControllerListener() {
    if (usernameTextEditingController.text.length > 5) {
      searchIntoUsersByUsername(
        username: usernameTextEditingController.text,
      );
    } else {
      page = 1;
      loadListOfUsers();
    }
  }

  void changeIsLoadingValueNotifier({bool? isLoading}) {
    isLoadingValueNotifier.value = isLoading ?? !isLoadingValueNotifier.value;
  }

  Future<void> loadListOfUsers() async {
    try {
      if (hasMoreUsersToLoad) {
        changeIsLoadingValueNotifier(
          isLoading: true,
        );
        final List<UserModel> users =
            await userRepositoryFunctions.getAllUsersPerPage(
          page: page,
          token: context.readAppBloc.state.currentUser.token ?? '',
        );
        hasMoreUsersToLoad = users.isNotEmpty;
        changeIsLoadingValueNotifier(
          isLoading: false,
        );
        changeListOfUsersValueNotifier(users: users);
        page++;
      }
    } catch (e) {
      context.readAppBloc.addError(e);
    }
  }

  void listOfUsersScrollControllerListener() {
    if (listOfUsersScrollController.offset >=
        listOfUsersScrollController.position.maxScrollExtent - 20) {
      loadListOfUsers();
    }
  }

  void changeListOfUsersValueNotifier({required List<UserModel> users}) {
    listOfUsersValueNotifier.value = users;
  }

  void addListOfUsersToListOfUsersValueNotifier(
      {required List<UserModel> listOfUsers}) {
    final List<UserModel> users = listOfUsersValueNotifier.value;
    changeListOfUsersValueNotifier(users: []);
    users.addAll(listOfUsers);
    changeListOfUsersValueNotifier(users: users);
  }

  void dispositionalDatas() {
    usernameTextEditingController
        .removeListener(usernameTextEditingControllerListener);
    usernameTextEditingController.dispose();
    listOfUsersScrollController
        .removeListener(listOfUsersScrollControllerListener);
    listOfUsersScrollController.dispose();
    listOfUsersValueNotifier.dispose();
    isLoadingValueNotifier.dispose();
  }

  @override
  void initState() {
    super.initState();
    initializeDatas();
  }

  @override
  void dispose() {
    dispositionalDatas();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.manageUsers),
      ),
      body: Column(
        children: [
          const CustomSpaceWidget(),
          TextField(
            controller: usernameTextEditingController,
            decoration: AppConfigs.customInputDecoration.copyWith(
              labelText: AppTexts.enterUsername,
            ),
          ),
          const CustomSpaceWidget(),
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: isLoadingValueNotifier,
              builder: (context, isLoading, child) {
                return isLoading ? const LoadingWidget() : child!;
              },
              child: ValueListenableBuilder<List<UserModel>>(
                valueListenable: listOfUsersValueNotifier,
                builder: (context, users, _) {
                  return ListView.builder(
                    controller: listOfUsersScrollController,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final UserModel user = users[index];
                      return ListTile(
                        title: Text(
                          user.username ?? '',
                        ),
                        leading: IconButton(
                          icon: const Icon(Icons.person_outline),
                          onPressed: () {
                            if (user.id > 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UsersDetailsScreen(
                                    userModel: user,
                                  ),
                                ),
                              );
                            }
                          },
                          tooltip: AppTexts.editUser,
                        ),
                        subtitle: InkWell(
                          onTap: () {
                            if (user.id > 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserBetsScreen(
                                    user: user,
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            AppTexts.showUserBets,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.monetization_on_outlined,
                          ),
                          tooltip: AppTexts.transactionsList,
                          onPressed: () {
                            if (user.id > 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransactionsListScreen(
                                    userId: user.id,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
