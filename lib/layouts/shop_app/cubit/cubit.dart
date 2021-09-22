import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/layouts/shop_app/cubit/states.dart';
import 'package:shop/models/shop_app/categories_model.dart';
import 'package:shop/models/shop_app/change_favorites_model.dart';
import 'package:shop/models/shop_app/favorites_model.dart';
import 'package:shop/models/shop_app/home_model.dart';
import 'package:shop/models/shop_app/login_model.dart';
import 'package:shop/modules/shop_app/categories/categories_screen.dart';
import 'package:shop/modules/shop_app/favorites/favorites_screen.dart';
import 'package:shop/modules/shop_app/products/products_screen.dart';
import 'package:shop/modules/shop_app/setting/setting_screen.dart';
import 'package:shop/shared/component/constant.dart';
import 'package:shop/shared/network/end_points.dart';
import 'package:shop/shared/network/remote/dio_helper.dart';

class ShopCubit extends Cubit<ShopStates>{
  ShopCubit() : super(ShopInitialState());

  static ShopCubit get(context)=>BlocProvider.of(context);
  int currentIndex =0;
  List<Widget> bottomScreens=[
ProductsScreen(),
    CategoriesScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];
  void changebottom(int index){
    currentIndex= index;
    emit(ShopChangeBottomNavState());
  }

  HomeModel homeModel;
  Map<int,bool> favorites ={};

  void getHomeData()
  {
    emit(ShopLoadingHomeDataState());
    DioHelper.getData(url: HOME,
      token: token,
    ).then((value) {
      print(value);
      homeModel= HomeModel.fromJson(value.data);


      homeModel.data.products.forEach((element) {
        favorites.addAll({
          element.id:element.isFavorites,
        });
      });
      print(favorites.toString());

      emit(ShopSuccessHomeDataState());
    }).catchError((error){
      print(error.toString());
      emit(ShopErrorHomeDataState());
    });
  }
  CategoriesModel categoriesModel;

  void getCategories()
  {

    DioHelper.getData(url: GET_CATEGORIZE,
      token: token,
    ).then((value) {
      print(value);
      categoriesModel= CategoriesModel.fromJson(value.data);

      emit(ShopSuccessCategoriesState());
    }).catchError((error){

      print(error.toString());
      emit(ShopErrorCategoriesState());
    });
  }

  ChangeFavoritesModel changeFavoritesModel;
  void changeFavorites(int productId) {
    favorites[productId] =! favorites[productId];
    emit(ShopChangeFavoritesState());

    DioHelper.PostData(url: FAVORITES,
        data: {'product_id':productId},
    token: token
    ).then((value) {
      changeFavoritesModel= ChangeFavoritesModel.fromJson(value.data);
      print(value.data);

      if(!changeFavoritesModel.status ){
        favorites[productId] =! favorites[productId];
      } else{
        getFavorites();
      }
     emit(ShopSuccessChangeFavoritesState(changeFavoritesModel));

    }).catchError((error){
      favorites[productId] =! favorites[productId];
      emit(ShopErrorChangeFavoritesState());
    });
  }


  FavoritesModel favoritesModel;

  void getFavorites()
  {
   emit(ShopLoadingGetFavoritesState());
    DioHelper.getData(url: FAVORITES,
      token: token,
    ).then((value) {
      print(value);
      favoritesModel= FavoritesModel.fromJson(value.data);
      printFullText(value.data.toString());

      emit(ShopSuccessGetFavoritesState());
    }).catchError((error){

      print(error.toString());
      emit(ShopErrorGetFavoritesState());
    });
  }

  ShopLoginModel userModel;

  void getUserData()
  {
    emit(ShopLoadingUserDataState());
    DioHelper.getData(url: PROFILE,
      token: token,
    ).then((value) {
      print(value);
      userModel= ShopLoginModel.fromJson(value.data);
      printFullText(userModel.data.name);

      emit(ShopSuccessUserDataState());
    }).catchError((error){

      print(error.toString());
      emit(ShopErrorUserDataState());
    });
  }

  void updateUserData({
    @required String name,
    @required String email,
    @required String phone,
  }) {
    emit(ShopLoadingUpdateUserState());

    DioHelper.PutData(
      url: UPDATE_PROFILE,
      token: token,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
      },
    ).then((value) {
      userModel = ShopLoginModel.fromJson(value.data);
      printFullText(userModel.data.name);

      emit(ShopSuccessUpdateUserState(userModel));
    }).catchError((error) {
      print(error.toString());
      emit(ShopErrorUpdateUserState());
    });
  }


}