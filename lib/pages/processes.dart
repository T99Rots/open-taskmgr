import 'package:flutter/material.dart';

class ProcessesPage extends StatefulWidget {
  ProcessesPage({Key key}) : super(key: key);

  @override
  _ProcessesPageState createState() => _ProcessesPageState();
}

class _ProcessesPageState extends State<ProcessesPage> {
  ScrollController _controller = ScrollController();
  int selected;

  void toggleSelected (int index) {
    setState(() {
      if(index == selected) {
        selected = null;
      } else {
        selected = index;
      }      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[700]),
              top: BorderSide(color: Colors.grey[700]),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 60,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Name'),
                    ),
                  ),
                ),
              ),
              ...['CPU', 'Memory', 'Disk', 'Network'].map<Widget>((str) => Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey[700])
                  ),
                ),
                width: 100,
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '38%',
                        style: TextStyle(
                          fontSize: 24
                        ),
                      ),
                      Text(
                        str,
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              )).toList(),
              Container(
                width: 100,
              )
            ],
          ),
        ),
        Expanded(
          child: Scrollbar(
            controller: _controller,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      if(index == 0 || index == 12) {
                        return Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20, left: 20, bottom: 10),
                                child: Text(
                                  index == 0?'Apps (11)':'Background processes (108)',
                                  style: TextStyle(
                                    fontSize: 20
                                  ),
                                ),
                              )
                            ),
                            ...List.generate(4, (_) => Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: Colors.grey[700])
                                ),
                                color: Colors.blue.withOpacity(0.07),
                              ),
                              width: 100,
                              height: 55,
                            )),
                            Container(
                              width: 100,
                            )
                          ],
                        );
                      } else {
                        return InkWell(
                          child: Container(
                            color: selected != index?null: Theme.of(context).backgroundColor,
                            height: 30,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 40, top: 8.0, bottom: 8),
                                    child: Text('Process $index'),
                                  ),
                                ),
                                ...['32.5%', '1,543 MB', '0.3 MB/s', '0.1 Mbps'].map<Widget>((str) => Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(color: Colors.grey[700])
                                    ),
                                    color: Colors.blue.withOpacity(0.2),
                                  ),
                                  width: 100,
                                  height: 30,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      str,
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                )).toList(),
                                Container(
                                  width: 100,
                                )
                              ],
                            ),
                          ),
                          onTap: selected == index? null: () {
                            toggleSelected(index);
                          },
                        );
                      }
                    },
                    childCount: 120
                  )
                )
              ]
            ),
          ),
        ),
      ],
    );
  }
}