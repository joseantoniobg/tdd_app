import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdd_app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:tdd_app/features/number_trivia/presentation/widgets/widgets.dart';
import 'package:tdd_app/injection_container.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NumberTrivia'),
      ),
      body: SingleChildScrollView(
        child: buildBody(context),
      ),
    );
  }

  BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NumberTriviaBloc>(),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              //top half
              SizedBox(height: 10),
              BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                builder: (context, state) {
                  if (state is Empty) {
                    return MessageDisplayWidget(
                      message: 'Start searching!',
                    );
                  } else if (state is Error) {
                    return MessageDisplayWidget(message: state.errorMessage);
                  } else if (state is Loaded) {
                    return TriviaDisplayWidget(numberTrivia: state.trivia);
                  } else if (state is Loading) {
                    return LoadingDisplayWidget();
                  }
                },
              ),

              SizedBox(height: 20),
              // botton half
              TriviaControlWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
