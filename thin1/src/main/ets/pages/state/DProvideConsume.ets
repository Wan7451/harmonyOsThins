/**
 * @Provide装饰器和@Consume装饰器：与后代组件双向同步
 *
 * @Provide和@Consume，应用于与后代组件的双向数据同步，应用于状态数据在多个层级之间传递的场景。
 * @Provide和@Consume摆脱参数传递机制的束缚，实现跨层级传递。
 *
 * @Provide装饰的变量是在祖先组件中，可以理解为被“提供”给后代的状态变量。
 * @Consume装饰的变量是在后代组件中，去“消费（绑定）”祖先组件提供的变量。
 *
 * @Provide装饰的状态变量自动对其所有后代组件可用，即该变量被“provide”给他的后代组件。
 * 后代通过使用@Consume去获取@Provide提供的变量，建立在@Provide和@Consume之间的双向数据同步
 *
 * @Provide和@Consume可以通过相同的变量名或者相同的变量别名绑定，建议类型相同，否则会发生类型隐式转换，从而导致应用行为异常。
 *
 * @Provide和@Consume通过相同的变量名或者相同的变量别名绑定时，@Provide装饰的变量和@Consume装饰的变量是一对多的关系。
 * 不允许在同一个自定义组件内，包括其子组件中声明多个同名或者同别名的@Provide装饰的变量，会发生运行时报错。
 *
 *
 * @Provide变量装饰器
 *
 * 装饰器参数        别名：常量字符串，可选。
 *                  如果指定了别名，则通过别名来绑定变量；如果未指定别名，则通过变量名绑定变量。
 *
 * 同步类型         双向同步。
 *                  从@Provide变量到所有@Consume变量以及相反的方向的数据同步。双向同步的操作与@State和@Link的组合相同。
 *
 * 允许装饰的变量类型  Object、class、string、number、boolean、enum类型，以及这些类型的数组。
 *                  支持Date类型。支持Map、Set类型。
 *                  支持上述支持类型的联合类型，比如string | number, string | undefined 或者 ClassA | null
 *
 * 支持ArkUI框架定义的联合类型Length、   必须指定类型。
 * ResourceStr、ResourceColor类型。   @Provide变量的@Consume变量的类型必须相同。
 * 不支持any。
 *
 * 被装饰变量的初始值    必须指定。
 *
 * 支持allowOverride参数   允许重写，只要声明了allowOverride，则别名和属性名都可以被Override。
 *
 * 从父组件初始化和更新   可选，允许父组件中常规变量（常规变量对@Provide，只是数值的初始化，常规变量的变化不会触发UI刷新，
 *                      只有状态变量才能触发UI刷新）、@State、@Link、@Prop、@Provide、@Consume、@ObjectLink、
 * @StorageLink、@StorageProp、@LocalStorageLink和@LocalStorageProp装饰的变量装饰变量
 *                     初始化子组件@Provide。
 * 用于初始化子组件      允许，可用于初始化@State、@Link、@Prop、@Provide。
 * 和父组件同步         否。
 * 和后代组件同步       和@Consume双向同步。
 * 是否支持组件外访问    私有，仅可以在所属组件内访问。
 *
 * #########################################################################################################
 * @Consume变量装饰器
 *
 * 装饰器参数        别名：常量字符串，可选。
 *                 如果提供了别名，则必须有@Provide的变量和其有相同的别名才可以匹配成功；
 *                  否则，则需要变量名相同才能匹配成功。
 *
 * 同步类型         双向：从@Provide变量（具体请参见@Provide）到所有@Consume变量，以及相反的方向。
 *                 双向同步操作与@State和@Link的组合相同。
 *
 * 允许装饰的变量类型    Object、class、string、number、boolean、enum类型，以及这些类型的数组。
 *                    支持Date类型。
 *                   支持上述支持类型的联合类型，比如string | number, string | undefined 或者 ClassA | null
 *
 * 支持ArkUI框架定义的联合类型Length、         必须指定类型。
 * ResourceStr、ResourceColor类型。         @Provide变量和@Consume变量的类型必须相同。
 * 不支持any。                              @Consume装饰的变量，在其父组件或者祖先组件上，必须有对应的属性和别名的@Provide装饰的变量。
 *
 *
 * 被装饰变量的初始值  无，禁止本地初始化。
 *
 * 从父组件初始化和更新  禁止。通过相同的变量名和alias（别名）从@Provide初始化。
 *
 * 用于初始化子组件    允许，可用于初始化@State、@Link、@Prop、@Provide。
 *
 * 和祖先组件同步      和@Provide双向同步。
 *
 * 是否支持组件外访问   私有，仅可以在所属组件内访问
 *
 * 观察变化
 *
 * 当装饰的数据类型为boolean、string、number类型时，可以观察到数值的变化。
 * 当装饰的数据类型为class或者Object的时候，可以观察到赋值和属性赋值的变化（属性为Object.keys(observedObject)返回的所有属性）。
 * 当装饰的对象是array的时候，可以观察到数组的添加、删除、更新数组单元。
 * 当装饰的对象是Date时，可以观察到Date整体的赋值
 * 当装饰的变量是Map时，可以观察到Map整体的赋值，同时可通过调用Map的接口set, clear, delete 更新Map的值。
 * 当装饰的变量是Set时，可以观察到Set整体的赋值，同时可通过调用Set的接口add, clear, delete 更新Set的值。
 *
 *
 * 框架行为
 * 1. 初始渲染：
 *    a. @Provide装饰的变量会以map的形式，传递给当前@Provide所属组件的所有子组件；
 *    b. 子组件中如果使用@Consume变量，则会在map中查找是否有该变量名/alias（别名）对应的@Provide的变量，
 *        如果查找不到，框架会抛出JS ERROR；
 *    c. 在初始化@Consume变量时，和@State/@Link的流程类似，@Consume变量会在map中查找到对应的@Provide变量进行保存，
 *        并把自己注册给@Provide。
 *
 * 2. 当@Provide装饰的数据变化时：
 *    a. 通过初始渲染的步骤可知，子组件@Consume已把自己注册给父组件。父组件@Provide变量变更后，会遍历更新所有依赖它的系统组件
 *        （elementid）和状态变量（@Consume）；
 *    b. 通知@Consume更新后，子组件所有依赖@Consume的系统组件（elementId）都会被通知更新。以此实现@Provide对@Consume状态数据同步。
 *
 * 3. 当@Consume装饰的数据变化时：
 *    通过初始渲染的步骤可知，在@Consume更新后调用@Provide的更新方法，将更新的数值同步回@Provide，以此实现@Consume向
 * @Provide的同步更新。
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 */

@Entry
@Component
struct DProvideConsume {
  @Provide map: Map<string, string> = new Map([["k1", "v1"], ["k2", "v2"]]);

  build() {
    Column() {
      PCComponent()
    }

  }
}


@Component
struct PCComponent {
  @Consume map: Map<string, string>

  build() {

    Column(){
    }

  }
}