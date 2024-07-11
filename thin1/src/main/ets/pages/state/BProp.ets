/**
 * @Prop装饰的变量可以和父组件建立单向的同步关系。
 * @Prop装饰的变量是可变的，但是变化不会同步回其父组件。
 *
 * 1. @Prop变量允许在本地修改，但修改后的变化不会同步回父组件。
 * 2. 当数据源更改时，@Prop装饰的变量都会更新，并且会覆盖本地所有更改。
 *    因此，数值的同步是父组件到子组件（所属组件)，子组件数值的变化不会同步到父组件。
 * 3. @Prop装饰变量时会进行深拷贝，在拷贝的过程中除了基本类型、Map、Set、Date、Array外，都会丢失类型。
 * 4. @Prop装饰器不能在@Entry装饰的自定义组件中使用。
 *
 *
 * 装饰器参数            无
 * 同步类型             单向同步：对父组件状态变量值的修改，将同步给子组件@Prop装饰的变量，
 *                     子组件@Prop变量的修改不会同步到父组件的状态变量上。
 *
 * 允许装饰的变量类型     Object、class、string、number、boolean、enum类型，以及这些类型的数组。
 *                     不支持any，支持undefined和null。支持Date类型。
 *                     支持上述支持类型的联合类型，比如string | number, string | undefined 或者 ClassA | null
 *
 * 支持ArkUI框架定义的   必须指定类型。
 * 联合类型Length、      @Prop和数据源类型需要相同，有以下三种情况：
 * ResourceStr、         - @Prop装饰的变量和@State以及其他装饰器同步时双方的类型必须相同，
 * ResourceColor类型。   - @Prop装饰的变量和@State以及其他装饰器装饰的数组的项同步时 ，@Prop的类型需要和@State装饰的数组的数组项相同，
 *                             比如@Prop : T和@State : Array<T>，
 *                      - 当父组件状态变量为Object或者class时，@Prop装饰的变量和父组件状态变量的属性类型相同
 *
 * 嵌套传递层数         在组件复用场景，建议@Prop深度嵌套数据不要超过5层，嵌套太多会导致深拷贝占用的空间过大以及
 *                        GarbageCollection(垃圾回收)，引起性能问题，此时更建议使用@ObjectLink。
 *
 * 被装饰变量的初始值    允许本地初始化。如果在API 11中和@Require结合使用，则必须父组件构造传参。
 *
 * 从父组件初始化       如果本地有初始化，则是可选的。没有的话，则必选，支持父组件中的常规变量（常规变量对@Prop赋值，只是数值的初始化，
 *                    常规变量的变化不会触发UI刷新。只有状态变量才能触发UI刷新）、@State、@Link、@Prop、@Provide、@Consume、
 * @ObjectLink、@StorageLink、@StorageProp、@LocalStorageLink和@LocalStorageProp去初始化子组件中的@Prop变量。
 *
 * 用于初始化子组件     @Prop支持去初始化子组件中的常规变量、@State、@Link、@Prop、@Provide。
 *
 * 是否支持组件外访问    @Prop装饰的变量是私有的，只能在组件内访问。
 *
 *
 * @Prop装饰的数据可以观察到以下变化。
 * - 当装饰的类型是允许的类型，即Object、class、string、number、boolean、enum类型都可以观察到赋值的变化。
 * - 当装饰的类型是Object或者class复杂类型时，可以观察到第一层的属性的变化，属性即Object.keys(observedObject)返回的所有属性；
 *      对于嵌套场景，如果class是被@Observed装饰的，可以观察到class属性的变化
 * - 当装饰的类型是数组的时候，可以观察到数组本身的赋值和数组项的添加、删除和更新。
 *
 *
 *  对于@State和@Prop的同步场景：
 *  1. 使用父组件中@State变量的值初始化子组件中的@Prop变量。当@State变量变化时，该变量值也会同步更新至@Prop变量。
 *  2. @Prop装饰的变量的修改不会影响其数据源@State装饰变量的值。
 *  3. 除了@State，数据源也可以用@Link或@Prop装饰，对@Prop的同步机制是相同的。
 *  4. 当装饰的对象是Date时，可以观察到Date整体的赋值，
 *  5. 当装饰的变量是Map时，可以观察到Map整体的赋值，同时可通过调用Map的接口set, clear, delete 更新Map的值。
 *  6. 当装饰的变量是Set时，可以观察到Set整体的赋值，同时可通过调用Set的接口add, clear, delete 更新Set的值。
 *
 *
 * 初始渲染：
 * 执行父组件的build()函数将创建子组件的新实例，将数据源传递给子组件；
 * 初始化子组件@Prop装饰的变量。
 * 更新：
 * 子组件@Prop更新时，更新仅停留在当前子组件，不会同步回父组件；
 * 当父组件的数据源更新时，子组件的@Prop装饰的变量将被来自父组件的数据源重置，所有@Prop装饰的本地的修改将被父组件的更新覆盖。
 *
 * @Prop装饰的数据更新依赖其所属自定义组件的重新渲染，所以在应用进入后台后，@Prop无法刷新，推荐使用@Link代替。
 *
 * ** @Prop 父组件传过来的值会缓存到子组件中，如果子组件中对应的值发生变化，父组件的值没有变化，更新父组件时，子组件不会刷新UI **
 *
 *
 *
 */
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct BProp {
  build() {
    Column() {
      ParentComponent()
      Library()
    }
  }
}


@Component
struct ChildComponent {
  @Require @Prop value: number = 10
  @Prop item: number = 0
  step: number = 2

  build() {
    Column() {
      Text(`child value is ${this.value}`)
      Button("+1")
        .onClick(() => {
          this.value += this.step
        })
      Button("-1")
        .onClick(() => {
          this.value -= this.step
        })
    }
  }
}


@Component
struct TextOnly {
  @Prop value: number = 0

  build() {
    Text(`${this.value}`)
      .onClick(() => {
        this.value++
      })
  }
}

@Component
struct ParentComponent {
  @State value: number = 10
  @State arrays: number[] = [1, 2, 3]

  build() {
    Column() {
      Text(`parent value is ${this.value}`)
      Button("+1")
        .onClick(() => {
          this.value++
          this.arrays = [456, 234, 456] //只有首次会更新，后续的值没有变化就不会更新
        })
      Button("-1")
        .onClick(() => {
          this.value--
          this.arrays[3] = 10
        })

      ChildComponent({ value: this.value, step: 2 })

      ForEach(this.arrays, (item: number) => {
        TextOnly({ value: item })
      })
    }

  }
}

/**
 * ⚠️注意这段话
 *
 * this.arr的更改触发ForEach更新，this.arr更新的前后都有数值为3的数组项：[3, 4, 5] 和[1, 2, 3]。
 * 根据diff算法，数组项“3”将被保留，删除“1”和“2”的数组项，添加为“4”和“5”的数组项。
 * 这就意味着，数组项“3”的组件不会重新生成，而是将其移动到第一位。所以“3”对应的组件不会更新，
 * 此时“3”对应的组件数值为“7”，ForEach最终的渲染结果是“7”，“4”，“5”。
 */


//需要使用@Observed装饰class Book，Book的属性将被观察。
//@Observed装饰的类的实例会被不透明的代理对象包装，此代理可以检测到包装对象内的所有属性更改。
@Observed
class Book2 {
  public title: string;
  public pages: number
  public readIt: boolean = false //第二层的嵌套属性，@State装饰器只能观察到第一层属性。

  constructor(title: string, pages: number) {
    this.title = title
    this.pages = pages
  }
}

@Component
struct ReaderComp {
  @Prop book: Book2 = new Book2("", 0)

  build() {
    Column() {
      Text(`${this.book.title}   ${this.book.pages}`)
      Text(`${this.book.readIt ? " 看过 " : "没看过"}`)
        .onClick(() => {
          this.book.readIt = true
        })
    }
  }
}

@Component
struct BookTestComponent {
  //为了支持@Component装饰的组件复用场景，@Prop支持本地初始化，这样可以让@Prop是否与父组件建立同步关系变得可选。
  //当且仅当@Prop有本地初始化时，从父组件向子组件传递@Prop的数据源才是可选的。
  @Prop param1: string = "第一个参数"
  @Prop param2: string //没有本地初始化，所以需要父组件提供数据源去初始化@Prop

  build() {

    Text(`${this.param1} ${this.param2} `)

  }
}


@Component
struct Library {
  @State book: Book2 = new Book2("小玩啤酒吧激情营业", 345)
  @State allBooks: Book2[] = [new Book2("C#", 765), new Book2("JS", 652), new Book2("TS", 765)];
  @State test: BTest2 = new BTest2(new BTest1("test1"), "test2")

  build() {
    Column() {
      ReaderComp({ book: this.book })
      Divider().height(10)
      ReaderComp({ book: this.book })
      Divider().height(30)


      ForEach(this.allBooks, (book: Book2) => {
        ReaderComp({ book: book })
          .margin(12)
          .width(312)
          .height(40)
          .padding({ left: 20, top: 10 })
          .backgroundColor('#0d000000')
          .borderRadius(20)
      })

      Button("Mark read for everyone")
        .width(312)
        .height(40)
        .margin(12)
        .fontColor('#FFFFFF 90%')
        .onClick(() => {
          this.allBooks.forEach((book) => book.readIt = true)
        })

      //param的类型复合类型 string ｜ undefined
      BookTestComponent({ param2: '第二个参数' })

      Divider().height(30)

      Text(`${this.test.title}   ${this.test.b.title}`)
        .backgroundColor('#ededed')
        .onClick(() => {
          //this.test.title = "haha"
          this.test.b.title = "点击了" //只有一级的数据变化才会更新，只有二级变化不会更新
          promptAction.showToast({
            message: "点击了"
          })
        })
      //可以收到二级变化的更新
      BTest2Component({ test: this.test.b })
    }
  }
}

@Component
struct BTest2Component {
  @Prop test: BTest1

  build() {
    Text(`${this.test.title} `)
  }
}


@Observed
class BTest1 {
  public title: string

  constructor(title: string) {
    this.title = title
  }
}

@Observed
class BTest2 {
  public b: BTest1
  public title: string

  constructor(b: BTest1, title: string) {
    this.b = b
    this.title = title
  }
}