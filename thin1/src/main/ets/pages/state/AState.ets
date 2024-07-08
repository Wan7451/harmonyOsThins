/**
 * 状态管理
 *
 * 在声明式UI编程框架中，UI是程序状态的运行结果，用户构建了一个UI模型，其中应用的运行时的状态是参数。
 * 当参数改变时，UI作为返回结果，也将进行对应的改变。
 * 这些运行时的状态变化所带来的UI的重新渲染，在ArkUI中统称为状态管理机制。
 *
 * 自定义组件拥有变量，变量必须被装饰器装饰才可以成为状态变量，状态变量的改变会引起UI的渲染刷新。
 *
 *
 * 1. 状态变量：被状态装饰器装饰的变量，状态变量值的改变会引起UI的渲染更新。
 * 2. 常规变量：没有被状态装饰器装饰的变量，通常应用于辅助计算。它的改变永远不会引起UI的刷新。
 * 3. 数据源/同步源：状态变量的原始来源，可以同步给不同的状态数据。通常意义为父组件传给子组件的数据。
 * 4. 命名参数机制：父组件通过指定参数传递给子组件的状态变量，为父子传递同步参数的主要手段。
 * 5. 从父组件初始化：父组件使用命名参数机制，将指定参数传递给子组件。子组件初始化的默认值在有父组件传值的情况下，会被覆盖。
 * 6. 初始化子组件：父组件中状态变量可以传递给子组件，初始化子组件对应的状态变量。
 * 7. 本地初始化：在变量声明的时候赋值，作为变量的默认值。
 *
 *
 * V1
 *
 * 根据状态变量的影响范围，将所有的装饰器可以大致分为：
 * - 管理组件拥有状态的装饰器：组件级别的状态管理，可以观察组件内变化，和不同组件层级的变化，但需要唯一观察同一个组件树上
 *    ，即同一个页面内。
 * - 管理应用拥有状态的装饰器：应用级别的状态管理，可以观察不同页面，甚至不同UIAbility的状态变化，是应用内全局的状态管理。
 *
 * 从数据的传递形式和同步类型层面看，装饰器也可分为：
 * - 只读的单向传递；
 * - 可变更的双向传递。
 *
 *
 * Components部分的装饰器为组件级别的状态管理，Application部分为应用的状态管理。
 *
 * 通过@StorageLink/@LocalStorageLink实现应用和组件状态的双向同步，
 * 通过@StorageProp/@LocalStorageProp实现应用和组件状态的单向同步。
 *
 * Components级别的状态管理：
 *
 * - @State装饰的变量拥有其所属组件的状态，可以作为其子组件单向和双向同步的数据源。当其数值改变时，会引起相关组件的渲染刷新。
 * - @Prop装饰的变量可以和父组件建立单向同步关系，@Prop装饰的变量是可变的，但修改不会同步回父组件。
 * - @Link装饰的变量可以和父组件建立双向同步关系，子组件中@Link装饰变量的修改会同步给父组件中建立双向数据绑定的数据源，
 *    父组件的更新也会同步给@Link装饰的变量。
 * - @Provide/@Consume装饰的变量用于跨组件层级（多层组件）同步状态变量，可以不需要通过参数命名机制传递，
 *    通过alias（别名）或者属性名绑定。
 * - @Observed装饰class，需要观察多层嵌套场景的class需要被@Observed装饰。单独使用@Observed没有任何作用，
 *    需要和@ObjectLink、@Prop联用。
 * - @ObjectLink装饰的变量接收@Observed装饰的class的实例，应用于观察多层嵌套场景，和父组件的数据源构建双向同步。
 *
 *
 * Application级别的状态管理：
 *
 * - AppStorage是应用程序中的一个特殊的单例LocalStorage对象，是应用级的数据库，和进程绑定，
 *    通过@StorageProp和@StorageLink装饰器可以和组件联动。
 * - AppStorage是应用状态的“中枢”，将需要与组件（UI）交互的数据存入AppStorage，比如持久化数据PersistentStorage和
 *    环境变量Environment。UI再通过AppStorage提供的装饰器或者API接口，访问这些数据。
 * - 框架还提供了LocalStorage，AppStorage是LocalStorage特殊的单例。LocalStorage是应用程序声明的应用状态的内存“数据库”，
 *    通常用于页面级的状态共享，通过@LocalStorageProp和@LocalStorageLink装饰器可以和UI联动。
 *
 *
 * @Watch用于监听状态变量的变化。
 * $$运算符：给内置组件提供TS变量的引用，使得TS变量和内置组件的内部状态保持同步。
 *
 * =============================
 *
 * @State装饰的变量，
 *  或称为状态变量，一旦变量拥有了状态属性，就可以触发其直接绑定UI组件的刷新。当状态改变时，UI会发生对应的渲染改变。
 *
 * 1. @State装饰的变量，与声明式范式中的其他被装饰变量一样，是私有的，只能从组件内部访问，在声明时必须指定其类型和本地初始化。
 *    初始化也可选择使用命名参数机制从父组件完成初始化。
 * 2. @State装饰的变量与子组件中的@Prop装饰变量之间建立单向数据同步,与@Link、@ObjectLink装饰变量之间建立双向数据同步。
 * 3. @State装饰的变量生命周期与其所属自定义组件的生命周期相同。
 *
 *
 * 装饰器参数            无
 * 同步类型              不与父组件中任何类型的变量同步。
 * 允许装饰的变量类型      Object、class、string、number、boolean、enum类型，以及这些类型的数组。
 *                      支持Date类型，支持Map、Set类型。支持undefined和null类型。
 *                      支持上述支持类型的联合类型，比如string | number, string | undefined 或者 ClassA | null
 *                      当使用undefined和null的时候，建议显式指定类型，遵循TypeScript类型校验。
 *
 * 支持ArkUI框架定义的联合类型Length、ResourceStr、ResourceColor类型。
 * 类型必须被指定。不支持any。
 * 被装饰变量的初始值      必须本地初始化。
 *
 * 从父组件初始化         可选，从父组件初始化或者本地初始化。如果从父组件初始化将会覆盖本地初始化。
 *                      支持父组件中常规变量（常规变量对@State赋值，只是数值的初始化，常规变量的变化不会触发UI刷新，
 *                      只有状态变量才能触发UI刷新）、@State、@Link、@Prop、@Provide、@Consume、@ObjectLink、
 * @StorageLink、@StorageProp、@LocalStorageLink和@LocalStorageProp装饰的变量，
 *                      初始化子组件的@State。
 *
 * 用于初始化子组件        @State装饰的变量支持初始化子组件的常规变量、@State、@Link、@Prop、@Provide。
 * 是否支持组件外访问      不支持，只能在组件内访问。
 *
 * 并不是状态变量的所有更改都会引起UI的刷新，只有可以被框架观察到的修改才会引起UI刷新。
 */
import { HashMap } from '@kit.ArkTS'

@Entry
@Component
struct AState {
  //当装饰的数据类型为boolean、string、number类型时，可以观察到数值的变化。
  @State count: number | undefined = undefined
  @State content: string = "10"
  @State vestibule: boolean = true
  // class类型 当装饰的数据类型为class或者Object时，可以观察到自身的赋值的变化，和其属性赋值的变化
  @State title: ModuleA = new ModuleA("ModuleA", new ClassA("ModuleA"))
  //当装饰的对象是array时，可以观察到数组本身的赋值和添加、删除、更新数组的变化。
  @State lists: ClassA[] = [new ClassA("1"), new ClassA("2")]
  //当装饰的对象是Date时，可以观察到Date整体的赋值
  @State date: Date = new Date()
  //当装饰的变量是Map时，可以观察到Map整体的赋值，同时可通过调用Map的接口set, clear, delete 更新Map的值。
  @State map: Map<string, string> = new Map<string, string>() // todo HashMap 为啥不行，必须Map
  //当装饰的变量是Set时，可以观察到Set整体的赋值，同时可通过调用Set的接口add, clear, delete 更新Set的值。
  @State set: Set<string> = new Set();

  /**
   * 当状态变量被改变时，查询依赖该状态变量的组件；
   * 执行依赖该状态变量的组件的更新方法，组件更新渲染；
   * 和该状态变量不相关的组件或者UI描述不会发生重新渲染，从而实现页面渲染的按需更新。
   *
   *
   * 在状态管理中，类会被一层“代理”进行包装。
   * 当在组件中改变该类的成员变量时，会被该代理进行拦截，在更改数据源中值的同时，也会将变化通知给绑定的组件，从而实现观测变化与触发刷新。
   */
  build() {

    Column() {
      Text(`${this.title.value} ${this.title.name.value}`)
      Text(`${this.count} ${this.content}  ${this.vestibule}`)
        .onClick(() => {

          if (!this.count) {
            this.count = 100
          } else {
            this.count = this.count + 1
            if (this.count % 2 == 0) {
              this.count = undefined
            }
          }
          this.content = `${this.count}`
          this.vestibule = !this.vestibule
          this.title.value = `${this.count}` //class属性的赋值可以观察到
          this.title.name.value = `${this.count}` //嵌套属性的赋值观察不到。

          //this.lists.push(new ClassA("3"))
          //this.lists.pop()
          this.lists[2] = new ClassA("3") // 数组项赋值可以观察到
          this.lists[0].value = "new" // 嵌套的属性赋值观察不到

          this.date.setTime(new Date().getTime())

          this.map.set(`${this.count}`, new Date().toDateString())
          this.set.add(new Date().toString())
        })

      ForEach(this.lists, (item: ClassA) => {
        Text(`${item.value}`)
        Divider()
      })

      Button(`${this.date.toTimeString()}`)

      ForEach(Array.from(this.map.entries()), (item: [string, string]) => {
        Button(`${item[0]}  ${item[1]}`)
        Divider()
      })

      ForEach(Array.from(this.set.entries()), (item: string) => {
        Text(`${item}`)
        Divider()
      })
    }
  }
}

class ClassA {
  value: string

  constructor(value: string) {
    this.value = value
  }
}

class ModuleA {
  value: string
  name: ClassA

  constructor(value: string, name: ClassA) {
    this.value = value
    this.name = name
  }
}

























