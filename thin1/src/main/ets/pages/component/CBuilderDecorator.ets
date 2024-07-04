/**
 * 装饰器
 *
 * @Builder装饰器：自定义构建函数
 * @Builder所装饰的函数遵循build()函数语法规则，开发者可以将重复使用的UI元素抽象成一个方法，在build方法里调用。
 *
 * @BuilderParam用来装饰指向@Builder方法的变量（@BuilderParam是用来承接@Builder函数的），
 *    开发者可在初始化自定义组件时对此属性进行赋值，为自定义组件增加特定的功能。
 */

@Entry
@Component
struct CBuilderDecorator {
  @State label: string = "阿萨姆奶茶"

  build() {
    Column() {
      this.myTextView()
      globalBuilderUI({
        param1: this.label
      })
      globalBuilderUI2({
        param1: this.label
      })
      Button("点一点").onClick(() => {
        this.label = "好喝不～"
      })
      overBuilder(this.label)

      Parent()

      //可以将尾随闭包内的内容看做@Builder装饰的函数传给@BuilderParam。
      CustomContainer() {
        Text("尾包闭包")
      }

      global1.builder("这是个标题", 30)

      ForEach(global2, (item: WrappedBuilder<[string, number]>) => {
        item.builder("这是个内容", 30)
      })
    }

  }

  /**
   * @Builder装饰的函数也称为“自定义构建函数”。
   *
   * 允许在自定义组件内定义一个或多个@Builder方法，该方法被认为是该组件的私有、特殊类型的成员函数。
   * 自定义构建函数可以在所属组件的build方法和其他自定义构建函数中调用，但不允许在组件外调用。
   * 在自定义函数体中，this指代当前所属组件，组件的状态变量可以在自定义构建函数内访问。
   *    **建议通过this访问自定义组件的状态变量而不是参数传递。**
   *
   * 参数传递规则
   * 自定义构建函数的参数传递有按值传递和按引用传递两种，均需遵守以下规则：
   * 1. 参数的类型必须与参数声明的类型一致，不允许undefined、null和返回undefined、null的表达式。
   * 2. 在@Builder修饰的函数内部，不允许改变参数值。
   * 3. @Builder内UI语法遵循UI语法规则。
   * 4. 只有传入一个参数，且参数需要直接传入对象字面量才会按引用传递该参数，其余传递方式均为按值传递。
   */
  @Builder
  myTextView() {
    Text("Builder装饰器")
  }
}


class Tmp {
  param1: string = ""
}

/**
 * 全局自定义构建函数
 *
 * 通用UI组件可以使用,比如头像
 */
@Builder
function globalBuilderUI(params: Tmp) {
  //按引用传递参数时，传递的参数可为状态变量，且状态变量的改变会引起@Builder方法内的UI刷新。
  Text(`UseStateVarByReference: ${params.param1}`)
    .width('100%')
}

@Builder
function globalBuilderUI2($$: Tmp) {
  //按引用传递参数时，如果在@Builder方法内调用自定义组件，ArkUI提供$$作为按引用传递参数的范式。
  Column() {
    Text(`overBuilder===${$$.param1}`)
    HelloComponent({ message: $$.param1 })
    HelloComponent2({ message: $$.param1 })
  }
}


@Component
struct HelloComponent {
  @Link message: string;

  build() {
    Row() {
      Text(`HelloComponent===${this.message}`)
    }
  }
}

@Component
struct HelloComponent2 {
  @State message: string = "";

  build() {
    Row() {
      Text(`HelloComponent===${this.message}`)
    }
  }
}

/**
 *
 * 按值传递参数
 *
 * 调用@Builder装饰的函数默认按值传递。
 * 当传递的参数为状态变量时，状态变量的改变不会引起@Builder方法内的UI刷新。
 * 所以当使用状态变量的时候，推荐使用按引用传递。
 */
@Builder
function overBuilder(param1: string) {
  Row() {
    Text(`UseStateVarByValue: ${param1} `)
  }
}


//=============================================================

@Builder
function overBuilder2() {

}


/**
 * @BuilderParam用来**装饰**指向@Builder方法的变量（@BuilderParam是用来承接@Builder函数的），
 * 开发者可在初始化自定义组件时对此属性进行赋值，为自定义组件增加特定的功能。
 * 类似UI回调，对外暴露一些能调整UI的接口
 */
@Component
struct Child {
  label: string = "子View实现"

  @Builder
  doNothingBuilder() {

  }

  @Builder
  doNothingBuilder2($$: Tmp) {

  }

  // 使用自定义组件的自定义构建函数初始化@BuilderParam
  @BuilderParam customBuilderParam1: () => void = this.doNothingBuilder
  // 使用全局自定义构建函数初始化@BuilderParam
  @BuilderParam customBuilderParam2: () => void = overBuilder2
  //@BuilderParam装饰的方法类型需要和@Builder方法类型一致。
  @BuilderParam customBuilderParam3: ($$: Tmp) => void = this.doNothingBuilder2
  tmp: Tmp = {
    param1: this.label
  }

  build() {
    Column() {
      this.customBuilderParam1()
      this.customBuilderParam2()
      this.customBuilderParam3(this.tmp)
    }
  }
}

@Component
struct Parent {
  label: string = "父容器实现"

  @Builder
  componentBuilder() {
    Text(`${this.label}`)
  }

  /**
   * @BuilderParam装饰的方法类型需要和@Builder方法类型一致。
   */
  @Builder
  componentBuilder2($$: Tmp) {
    Text(`${$$.param1}`)
      .backgroundColor(Color.Red)
  }

  build() {

    Column() {
      this.componentBuilder() //label = "父容器实现"
      Child({
        customBuilderParam1: this.componentBuilder, //方法被传入到Child label = "子View实现"
        customBuilderParam2: () => {
          this.componentBuilder() //label  = "父容器实现"
        },
        customBuilderParam3: this.componentBuilder2
      }).backgroundColor(Color.Green)
        .width("100%")
        .height(100)
    }

  }
}


/**
 * @BuilderParam装饰的属性时也可通过尾随闭包进行初始化。
 * 在初始化自定义组件时，组件后紧跟一个大括号“{}”形成尾随闭包场景。
 *
 * 1. 自定义组件内有且仅有一个使用@BuilderParam装饰的属性。
 * 2. 自定义组件不支持使用通用属性。
 */
@Component
struct CustomContainer {
  @Builder
  doNothing() {

  }

  @BuilderParam customContainer: () => void = this.doNothing

  build() {
    this.customContainer()
  }
}


@Builder
function title(title: string, size: number) {
  Text(title).fontSize(size)
}

@Builder
function contentText1(title: string, size: number) {
  Text(title).fontSize(size)
}

@Builder
function contentText2(title: string, size: number) {
  Text(title).fontSize(size)
  Divider()
}

/**
 * wrapBuilder方法只能传入全局@Builder方法。
 *
 * wrapBuilder方法返回的WrappedBuilder对象的builder属性方法只能在struct内部使用。
 */
let global1 = wrapBuilder(title);

let global2 = [wrapBuilder(contentText1), wrapBuilder(contentText2)]



