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
 */
@Component
struct Child {
  @Builder
  doNothingBuilder() {

  }

  // 使用自定义组件的自定义构建函数初始化@BuilderParam
  @BuilderParam customBuilderParam: () => void = this.doNothingBuilder
  // 使用全局自定义构建函数初始化@BuilderParam
  @BuilderParam customOverBuilderParam: () => void = overBuilder2

  build() {
    Column() {
      Text("子View实现")
      this.customBuilderParam()
    }
  }
}

@Component
struct Parent {
  @Builder
  componentBuilder() {
    Text("父容器实现")
  }

  build() {
    Column() {
      Child({
        customBuilderParam: this.componentBuilder
      }).backgroundColor(Color.Green)
        .width("100%")
        .height(100)
    }
  }
}


