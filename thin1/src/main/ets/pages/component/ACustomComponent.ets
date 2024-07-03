import { promptAction } from '@kit.ArkUI';

/**
 *
 * 1. 创建自定义组件
 *
 *
 * @Entry装饰的自定义组件将作为UI页面的入口。
 * 在单个UI页面中，最多可以使用@Entry装饰一个自定义组件。
 * @Entry可以接受一个可选的LocalStorage的参数。
 *
 * todo LocalStorage  ?
 * todo EntryOptions ?
 * todo @Reusable装饰的自定义组件具备可复用能力
 */
@Entry
@Component
struct Index {
  //数据驱动UI更新：通过状态变量的改变，来驱动UI的刷新。
  @State message: string = 'Hello World'; //组件中的状态变量,状态变量变化会触发UI刷新。
  //点击方法,不能用 let, 箭头函数，可以直接调用
  click = () => {
    promptAction.showToast({
      message: "showToast"
    })
  }

  //使用组件的成员函数配置组件的事件方法，需要bind this。
  //不推荐使用成员函数配合bind this去配置组件的事件方法。
  myClick(): void {
    promptAction.showToast({
      message: this.message
    })
  }

  //框架直接提供的称为系统组件，由开发者定义的称为自定义组件。
  build() {
    RelativeContainer() { //创建组件时不需要new运算符。 需在尾随闭包"{...}"中为组件添加子组件的UI描述
      Text(this.message)
        .id('HelloWorld')//属性方法以“.”链式调用的方式配置系统组件的样式和其他属性，建议每个属性方法单独写一行。
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(this.click)//事件方法以“.”链式调用的方式配置系统组件支持的事件
        .onClick(() => { //箭头函数配置组件的事件
          promptAction.showToast({
            message: this.message
          })
        })
        .onClick(this.myClick.bind(this))
      ParentComponent()
        .width('100%')
        .height(100)
        .backgroundColor(Color.Blue)
    }
    .height('100%')
    .width('100%')
  }
}


@Component
struct ParentComponent {
  //将父组件中的函数传递给子组件，并在子组件中调用。
  parentDef = () => {
    promptAction.showToast({
      message: "上级事件"
    })
  }
  //参数得要是个对象，把需要的参数包起来
  param: HelloComponentParams = {
    message: "参数怎么传递的？",
    hint: "第二个参数",
    childUse: this.parentDef
  }

  build() {
    Column() {
      HelloComponent(this.param)
      Divider()
      HelloComponent(this.param)
    }.backgroundColor(Color.Red)
  }
}

class HelloComponentParams {
  message: string = ""
  hint: string = "hint"
  childUse?: () => void
}

/**
 * struct：自定义组件基于struct实现，struct + 自定义组件名 + {...}的组合构成自定义组件，不能有继承关系。
 * @Component装饰器仅能装饰struct关键字声明的数据结构。
 * struct被@Component装饰后具备组件化的能力，需要实现build方法描述UI，
 * 一个struct只能被一个@Component装饰。@Component可以接受一个可选的bool类型参数。
 *
 * @param freezeWhenInactive 是否开启组件冻结。
 *
 * ArkUI给自定义组件设置样式时，相当于给MyComponent2套了一个不可见的容器组件，
 * 而这些样式是设置在容器组件上的，而非直接设置给MyComponent2的Button组件。
 */
@Component({ freezeWhenInactive: true })
struct HelloComponent {
  @State message: string = "custom component"
  @State hint: string = "custom hint"
  //自定义组件的成员函数为私有的，且不建议声明成静态函数。
  //自定义组件的成员变量为私有的，且不建议声明成静态变量。
  private count: number = 10
  childUse?: () => void

  @Builder
  myTextView() {
    Text("my text view")
  }

  /**
   * 所有声明在build()函数的语句，我们统称为UI描述
   * build()函数用于定义自定义组件的声明式UI描述，自定义组件必须定义build()函数。
   * @Entry装饰的自定义组件，其build()函数下的根节点唯一且必要，且必须为容器组件
   * @Component装饰的自定义组件，其build()函数下的根节点唯一且必要，可以为非容器组件
   */
  build() {

    /**
     * 不允许声明本地变量
     * 不允许在UI描述里直接使用console.info
     * 不允许本地作用域
     * 不允许调用没有用@Builder装饰的方法，允许系统组件的参数是TS方法的返回值。
     * 不允许使用switch语法，如果需要使用条件判断，请使用if
     * 不允许使用表达式
     * 不允许直接改变状态变量,应避免直接在Text组件内改变count的值
     * 不能在自定义组件的build()或@Builder方法里直接改变状态变量，这可能会造成循环渲染的风险。
     * Text('${this.count++}')在全量更新或最小化更新会产生不同的影响：
     * 全量更新： ArkUI可能会陷入一个无限的重渲染的循环里，因为Text组件的每一次渲染都会改变应用的状态，就会再引起下一轮渲染的开启。
     * 最小化更新：在初次渲染时会导致Text组件渲染两次，从而对性能产生影响。
     *
     *
     * build函数中更改应用状态的行为可能会比上面的示例更加隐蔽，比如：
     * 在@Builder，@Extend或@Styles方法内改变状态变量 。
     * 在计算参数时调用函数中改变应用状态变量，例如 Text('${this.calcLabel()}')。
     * 对当前数组做出修改，sort()改变了数组this.arr，随后的filter方法会返回一个新的数组。
     */
    Row() {
      this.myTextView() //必须有 this
      Text(this.hint)
        .fontSize(30)
        .onClick(() => {
          this.hint = this.message
          //判空下
          if (this.childUse) {
            this.childUse()
          }
        });
    }

  }
}