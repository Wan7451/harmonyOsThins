/**
 * @Link装饰器：父子双向同步
 *
 * @Link装饰的变量与其父组件中的数据源共享相同的值。
 * @Link装饰器不能在@Entry装饰的自定义组件中使用。
 *
 * 装饰器参数          无
 * 同步类型            双向同步。
 *                   父组件中@State, @StorageLink和@Link 和子组件@Link可以建立双向数据同步，反之亦然。
 *
 * 允许装饰的变量类型   Object、class、string、number、boolean、enum类型，以及这些类型的数组。
 *                   支持Date类型。支持Map、Set类型
 *                   支持上述支持类型的联合类型，比如string | number, string | undefined 或者 ClassA | null
 *
 * 支持ArkUI框架定义的联合类型Length、ResourceStr、ResourceColor类型。
 * 类型必须被指定，且和双向绑定状态变量的类型相同。不支持any。
 *
 * 被装饰变量的初始值   无，禁止本地初始化。
 *
 * 从父组件初始化和更新  必选。与父组件@State, @StorageLink和@Link 建立双向绑定。
 *                    允许父组件中@State、@Link、@Prop、@Provide、@Consume、@ObjectLink、@StorageLink、
 * @StorageProp、@LocalStorageLink和@LocalStorageProp装饰变量初始化子组件@Link。
 *
 * 用于初始化子组件     允许，可用于初始化常规变量、@State、@Link、@Prop、@Provide。
 *
 * 是否支持组件外访问   私有，只能在所属组件内访问。
 *
 *
 *
 * 观察变化
 *
 * 当装饰的数据类型为boolean、string、number类型时，可以同步观察到数值的变化
 * 当装饰的数据类型为class或者Object时，可以观察到赋值和属性赋值的变化，即Object.keys(observedObject)返回的所有属性
 * 当装饰的对象是array时，可以观察到数组添加、删除、更新数组单元的变化，
 * 当装饰的对象是Date时，可以观察到Date整体的赋值
 * 当装饰的变量是Map时，可以观察到Map整体的赋值，同时可通过调用Map的接口set, clear, delete 更新Map的值
 * 当装饰的变量是Set时，可以观察到Set整体的赋值，同时可通过调用Set的接口add, clear, delete 更新Set的值
 *
 *
 * 框架行为
 *
 * @Link装饰的变量和其所属的自定义组件共享生命周期。
 *
 * 1. 初始渲染：执行父组件的build()函数后将创建子组件的新实例。初始化过程如下：
 *    a. 必须指定父组件中的@State变量，用于初始化子组件的@Link变量。子组件的@Link变量值与其父组件的数据源变量保持同步（双向数据同步）。
 *    b. 父组件的@State状态变量包装类通过构造函数传给子组件，子组件的@Link包装类拿到父组件的@State的状态变量后，将当前@Link包装类
 *       this指针注册给父组件的@State变量。
 * 2. @Link的数据源的更新：即父组件中状态变量更新，引起相关子组件的@Link的更新。处理步骤：
 *    a. 通过初始渲染的步骤可知，子组件@Link包装类把当前this指针注册给父组件。父组件@State变量变更后，会遍历更新所有依赖它的
 *        系统组件（elementid）和状态变量（比如@Link包装类）。
 *    b. 通知@Link包装类更新后，子组件中所有依赖@Link状态变量的系统组件（elementId）都会被通知更新。以此实现父组件对子组件的
 *        状态数据同步。
 * 3. @Link的更新：当子组件中@Link更新后，处理步骤如下（以父组件为@State为例）：
 *    a. @Link更新后，调用父组件的@State包装类的set方法，将更新后的数值同步回父组件。
 *    b. 子组件@Link和父组件@State分别遍历依赖的系统组件，进行对应的UI的更新。以此实现子组件@Link同步回父组件@State。
 *
 */

@Entry
@Component
struct CLink {
  @State content: string = "from entry"

  build() {
    Column() {
      LinkParent({ content: this.content }) {
        LinkChild({ content: this.content })
      }
    }
  }
}


@Component
struct LinkChild {
  @Link content: string

  build() {
    Column() {
      Text(this.content)
        .onClick(() => {
          this.content = "change from child"
        }).backgroundColor(Color.Red)
      Divider().height(20)
    }
  }
}

@Component
struct LinkChild2 {
  @Link items: number[]

  build() {
    Column() {
      Button("push")
        .margin(12)
        .width(312)
        .height(40)
        .fontColor('#FFFFFF,90%')
        .onClick(() => {
          this.items.push(this.items.length + 1)
        })

      Button('replace')
        .margin(12)
        .width(312)
        .height(40)
        .fontColor('#FFFFFF,90%')
        .onClick(() => {
          this.items = [100, 200, 300]
        })
    }
  }
}

@Component
struct LinkParent {
  @Link content: string
  @Require @BuilderParam childContent: () => void = this.child
  @State arr: number[] = [1, 2, 3]

  @Builder
  child() {
  }

  build() {
    Column() {
      Text(this.content)
        .onClick(() => {
          this.content = "change from parent"
        })
      this.childContent()

      LinkChild2({ items: this.arr })

      ForEach(this.arr, (item: number) => {
        Button(`${item}`)
          .margin(12)
          .width(312)
          .height(40)
          .backgroundColor('#11a2a2a2')
          .fontColor('#e6000000')
      }, (item: ForEachInterface) => item.toString())
    }
  }
}


























