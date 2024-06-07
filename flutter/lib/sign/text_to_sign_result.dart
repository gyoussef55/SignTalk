import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';

@immutable
class TextToSignResult extends StatelessWidget {
  TextToSignResult({required this.imagePaths , super.key});
  List<String> imagePaths;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text to Sign Result'),
        automaticallyImplyLeading: true,
      ),
      body:Swiper(
          
          loop: false,
         
          itemBuilder: (BuildContext context,int index){
            return Image.network("http://127.0.0.1:5000/get_image?image_path=${imagePaths[index]}",fit: BoxFit.contain,);
          },
          
          itemCount: imagePaths.length,
          pagination: const SwiperPagination(
            builder: SwiperPagination.fraction
          ),
          control: const SwiperControl(),
        ),
      
    
    );
  }
}