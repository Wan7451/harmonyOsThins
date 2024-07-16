/**
 * @Watch装饰器：状态变量更改通知
 *
 * @Watch应用于对状态变量的监听。如果开发者需要关注某个状态变量的值是否改变，可以使用@Watch为状态变量设置回调函数。
 * @Watch用于监听状态变量的变化，当状态变量变化时，@Watch的回调方法将被调用。
 * @Watch在ArkUI框架内部判断数值有无更新使用的是严格相等（===），遵循严格相等规范。当在严格相等为false的情况下，
 * 就会触发@Watch的回调。
 *
 *
 * 装饰器参数             必填。常量字符串，字符串需要有引号。是(string) => void自定义成员函数的方法的引用。
 * 可装饰的自定义组件变量   可监听所有装饰器装饰的状态变量。不允许监听常规变量。
 * 装饰器的顺序           建议@State、@Prop、@Link等装饰器在@Watch装饰器之前。
 *
 * (changedPropertyName? : string) => void
 * 该函数是自定义组件的成员函数，changedPropertyName是被watch的属性名。
 * 在多个状态变量绑定同一个@Watch的回调方法的时候，可以通过changedPropertyName进行不同的逻辑处理
 * 将属性名作为字符串输入参数，不返回任何内容。
 *
 *
 * 观察变化和行为表现
 *
 * 当观察到状态变量的变化（包括双向绑定的AppStorage和LocalStorage中对应的key发生的变化）的时候，对应的@Watch的回调方法将被触发；
 * @Watch方法在自定义组件的属性变更之后同步执行；
 * 如果在@Watch的方法里改变了其他的状态变量，也会引起状态变更和@Watch的执行；
 * 在第一次初始化的时候，@Watch装饰的方法不会被调用，即认为初始化不是状态变量的改变。只有在后续状态改变时，才会调用@Watch回调方法。
 *
 *
 * 限制条件
 *
 * 建议开发者避免无限循环。循环可能是因为在@Watch的回调方法里直接或者间接地修改了同一个状态变量引起的。为了避免循环的产生，
 * 建议不要在@Watch的回调方法里修改当前装饰的状态变量；
 * 开发者应关注性能，属性值更新函数会延迟组件的重新渲染（具体请见上面的行为表现），因此，回调函数应仅执行快速运算；
 * 不建议在@Watch函数中调用async await，因为@Watch设计的用途是为了快速的计算，异步行为可能会导致重新渲染速度的性能问题。
 *
 *
 * $$语法：内置组件双向同步
 *
 * $$运算符为系统内置组件提供TS变量的引用，使得TS变量和系统内置组件的内部状态保持同步。
 * 当前$$支持基础类型变量，以及@State、@Link和@Prop装饰的变量。
 * 当前$$支持的组件： xxxx
 * $$绑定的变量变化时，会触发UI的同步刷新。
 *
 *
 * @Track装饰器：class对象属性级更新
 *
 * @Track应用于class对象的属性级更新。@Track装饰的属性变化时，只会触发该属性关联的UI更新。
 * @Track是class对象的属性装饰器。当一个class对象是状态变量时，@Track装饰的属性发生变化，只会触发该属性关联的UI更新；
 * 而未被标记的属性不能在UI中使用。
 *
 * 装饰器参数             无
 * 可装饰的变量           class对象的非静态成员属性。
 *
 *
 */

@Component
struct TotalView {
  @Prop @Watch('onCountUpdated') count: number = 0;
  @State total: number = 0;

  // @Watch 回调
  onCountUpdated(propName: string): void {
    this.total += this.count;
  }

  build() {
    Text(`Total: ${this.total}`)
  }
}

@Entry
@Component
struct CountModifier {
  @State count: number = 0;

  build() {
    Column() {
      Button('add to basket')
        .onClick(() => {
          this.count++
        })
      TotalView({ count: this.count })
      TextInputExample()
      AddLog()
    }
  }
}


@Component
struct TextInputExample {
  @State text: string = ''
  controller: TextInputController = new TextInputController()

  build() {
    Column({ space: 20 }) {
      Text(this.text)
      TextInput({ text: $$this.text, placeholder: 'input your word...', controller: this.controller })
        .placeholderColor(Color.Grey)
        .placeholderFont({ size: 14, weight: 400 })
        .caretColor(Color.Blue)
        .width(300)
    }.width('100%').justifyContent(FlexAlign.Center)
  }
}


class LogTrack {
  @Track str1: string;
  @Track str2: string;

  constructor(str1: string) {
    this.str1 = str1;
    this.str2 = 'World';
  }
}

class LogNotTrack {
  str1: string;
  str2: string;

  constructor(str1: string) {
    this.str1 = str1;
    this.str2 = '世界';
  }
}

@Component
struct AddLog {
  @State logTrack: LogTrack = new LogTrack('Hello');
  @State logNotTrack: LogNotTrack = new LogNotTrack('你好');

  isRender(index: number) {
    console.log(`Text ${index} is rendered`);
    return 50;
  }

  build() {
    Row() {
      Column() {
        Text(this.logTrack.str1) // UINode1
          .fontSize(this.isRender(1))
          .fontWeight(FontWeight.Bold)
        Text(this.logTrack.str2) // UINode2
          .fontSize(this.isRender(2))
          .fontWeight(FontWeight.Bold)
        Button('change logTrack.str1')
          .onClick(() => {
            this.logTrack.str1 = 'Bye';
          })
        Text(this.logNotTrack.str1) // UINode3
          .fontSize(this.isRender(3))
          .fontWeight(FontWeight.Bold)
        Text(this.logNotTrack.str2) // UINode4
          .fontSize(this.isRender(4))
          .fontWeight(FontWeight.Bold)
        Button('change logNotTrack.str1')
          .onClick(() => {
            this.logNotTrack.str1 = '再见';
          })
      }
      .width('100%')
    }
  }
}