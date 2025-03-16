import 'package:dc_test/templating/framework/index.dart';
import 'package:flutter/material.dart' hide TextStyle, Text, View;

class MainApp extends Component {
  @override
  VNode buildRender() {
    // Using hooks for state management
    final counter = UseState<int>('counter', 0);

    return DCView(
      props: DCViewProps(
        style: DCViewStyle(
          padding: EdgeInsets.all(100),
          backgroundColor: Colors.amber,
        ),
      ),
      children: [
        DCView(
          props: DCViewProps(
            style: DCViewStyle(
              backgroundColor: Colors.indigo,
              padding: EdgeInsets.all(20),
            ),
          ),
          children: [
            DCButton(
              title: "Increment Counter",
              onPress: (_) {
                // Simpler state update with hooks
                counter.value += 1;
              },
            ),
            DCText(
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              // Reference hook value directly
              'Counter: ${counter.value}',
            ),
            DCText(
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              'Using DC framework with hooks',
            ),
          ],
        ),
      ],
    ).build();
  }
}

/* ALTERNATIVE IMPLEMENTATION USING CLASS-BASED STATE:
 * 
 * The above hooks-based component could alternatively be written using class state:
 * 
 * class MainApp extends Component {
 *   @override
 *   Map<String, dynamic> getInitialState() {
 *     return {'counter': 0};
 *   }
 * 
 *   @override
 *   VNode buildRender() {
 *     final counter = state['counter'] as int? ?? 0;
 *     
 *     return DCView(
 *       props: DCViewProps(
 *         style: DCViewStyle(
 *           padding: EdgeInsets.all(100),
 *           backgroundColor: Colors.amber,
 *         ),
 *       ),
 *       children: [
 *         DCView(
 *           props: DCViewProps(
 *             style: DCViewStyle(
 *               backgroundColor: Colors.indigo,
 *               padding: EdgeInsets.all(20),
 *             ),
 *           ),
 *           children: [
 *             DCButton(
 *               title: "Increment Counter",
 *               onPress: (_) {
 *                 setState({'counter': counter + 1});
 *               },
 *             ),
 *             DCText(
 *               style: TextStyle(
 *                 color: Colors.white,
 *                 fontSize: 24,
 *                 fontWeight: FontWeight.bold,
 *               ),
 *               'Counter: $counter',
 *             ),
 *             DCText(
 *               style: TextStyle(
 *                 color: Colors.white,
 *                 fontSize: 16,
 *               ),
 *               'Using DC framework with class state',
 *             ),
 *           ],
 *         ),
 *       ],
 *     ).build();
 *   }
 * }
 */
