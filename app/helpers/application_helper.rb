module ApplicationHelper
  def primary_entry_image_path(entry)
    e_image = entry.entry_images.first
    url_for(e_image)
  end

  def two_thumb_image_tag(entry)
    e_image = entry.entry_images.limit(2)
    if e_image.second
      [
        image_tag(e_image[0].variant(resize_to_limit: [700, 700]),
                                     class: "thumb-primary", alt: "Product"),
        image_tag(e_image[1].variant(resize_to_limit: [700, 700]),
                                     class: "thumb-secondary", alt: "Product")
      ]
    else
      [
        image_tag(e_image[0].variant(resize_to_limit: [700, 700]),
                                     class: "thumb-primary", alt: "Product"),
        image_tag(e_image[0].variant(resize_to_limit: [700, 700]),
                                     class: "thumb-secondary", alt: "Product")
      ]
    end
  end

  def ratting_stars_tag(entry)
    ratting = entry.vote_weight
    star_count = (ratting * 2).round.divmod(2)
    full_stars = star_count[0]
    half_stars = star_count[1]
    stars = Array.new(5, "star_outline")
      .fill("star", 0, full_stars)
      .fill("star_half", full_stars, half_stars)

    # <span><i class="material-icons yelstar">star</i></span>
    stars.map do |s|
      content_tag(:span, content_tag(:i, s, class: "material-icons yelstar"))
    end
  end

  def entry_images_slider_tag(entry)
    e_image = entry.entry_images.limit(5)
    e_image.map.with_index do |ei, ix|
      # <figure class="pro-thumb-item" data-mfp-src="assets/img/product/product-1.png">
      #     <img src="assets/img/product/product-1.png" alt="Product Details1" />
      # </figure>
      content_tag(
        :figure,
        image_tag(
          ei.variant(resize_to_limit: [700, 700]),
          alt: "Product Details#{ix + 1}"
        ),
        class: "pro-thumb-item",
        'data-mfp-src': url_for(ei.variant(resize_to_limit: [700, 700]))
      )
    end
  end

  def entry_images_slider_nav_tag(entry)
    e_image = entry.entry_images.limit(5)
    e_image.map.with_index do |ei, ix|
      # <figure class="pro-thumb-item">
      #     <img src="assets/img/product/product-1.png" alt="Product Details1" />
      # </figure>
      content_tag(
        :figure,
        image_tag(
          ei.variant(resize_to_limit: [300, 300]),
          alt: "Product Details#{ix + 1}"
        ),
        class: "pro-thumb-item"
      )
    end
  end

  def entry_specs_tag(entry)
    specs = entry.attributes.delete_if { |key, value| value == "" || value.nil? }
      .slice("maker", "model", "year", "serial", "madein", "sound",
             "price", "geartype", "guitarbody", "finish", "neck",
             "fboard", "peg", "fret", "scale", "pickup", "controlls",
             "bridge", "category")
      .to_a
    # <tr>
    #   <th class="config-label">Key</th>
    #   <td class="config-option">
    #     <div class="config-color">
    #        Value
    #     </div>
    #   </td>
    # </tr>
    specs.map do |s|
      content_tag :tr do
        (
          content_tag(:th, I18n.t(s[0]), class: "config-label")
        ) +
        (
          content_tag(:td, class: "config-option") do
            (
              if ["maker", "model"].include?(s[0])
                content_tag(
                  :div,
                  link_to(
                    simple_format(s[1]), "/entries?search%5Bq%5D=#{s[1]}&commit=Search",
                    class: "text-primary"
                  )
                )
              else
                content_tag(
                  :div,
                  simple_format(entry.send(s[0].to_sym)),
                  class: "config-color"
                )
              end
            )
          end
        )
      end
    end
  end

  def entry_list_tag(entry)
    #  <tr>
    #    <td class="product-list">
    #      <div class="cart-product-item d-flex align-items-center">
    #        <a href="single-product.html" class="product-thumb">
    #          <img src="assets/img/product/product-1.png" alt="Product" />
    #        </a>
    #        <a href="single-product.html" class="product-name">
    #          Fender Japan
    #        </a>
    #      </div>
    #    </td>
    #  </tr>
    content_tag :tr do
      content_tag :td, class: "product-list" do
        content_tag :div, class: "cart-product-item d-flex align-items-center" do
          (
            if entry.entry_images.first.present?
              link_to(
                image_tag(entry.entry_images.first.variant(resize_to_limit: [100, 100])),
                entry_path(entry),
                class: "product-thumb"
              )
            else
              link_to(
                "no image",
                entry_path(entry),
                class: "product-thumb"
              )
            end
          ) +
          (
            link_to(entry.heading.truncate(25), entry_path(entry), class: "product-name")
          )
        end
      end
    end
  end

  def collector_list_tag(collector)
    # <div class="rating-item">
    #   <div class="rating-author-pic">
    #     <img src="assets/img/extra/author-1.jpg" alt="author" />
    #   </div>
    #   <div class="rating-author-txt">
    #     owner name
    #   </div>
    # </div>
    content_tag :div, class: "rating-item" do
      (
        content_tag :div, class: "rating-author-pic" do
          if collector.profile.avatar_image.present?
            link_to(
              image_tag(
                collector.profile.avatar_image.variant(resize_to_limit: [150, 150]),
                style: "width: 50px; height: 50px; object-fit: cover;"
              ),
              profile_path(collector.profile)
            )
          else
            link_to(gravatar_image_tag(collector), profile_path(collector.profile))
          end
        end
      ) +
      (
        content_tag :div, class: "ating-author-txt" do
          link_to(collector.profile.login, profile_path(collector.profile))
        end
      )
    end
  end

  def gravatar_image_tag(member, *args)
    name = member.profile.login
    url = "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(name)}?d=retro"
    image_tag(url, *args)
  end

  def entry_card_tag(entry)
    content_tag :div, class: "col-md-6" do
      content_tag :div, class: "card m-3" do
        content_tag :div, class: "card-body" do
          (ect_1(entry)) + (ect_2(entry)) + (ect_3(entry)) 
        end
      end
    end
  end

  def ect_1(entry)
    link_to(
      (
        if entry.entry_images.present?
          image_tag(
            entry.entry_images.first.variant(resize_to_limit: [260, 260]),
            class: "img-thumbnail rounded",
            style: "min-width: 160px;"
          )
        else
          "THIS ITEMS PAGE DOSE NOT HAVE A IMAGE"
        end
      ),
      entry_path(entry),
      class: "m-3 mt-0"
    )
  end

  def ect_2(entry) 
    content_tag :div, class: "mt-3", style: "min-width: 200px;" do #1
    (
      content_tag :h5, class: "card-title mb-1" do
        link_to(entry.heading, entry_path(entry), style: "color: #3b5998;")
      end
    ) + #2
    (
      content_tag :p, class: "text-black-70 pt-1" do
        simple_format(entry.body.truncate(60)) if entry.body.present?
      end
    ) + #2
    (
      content_tag :div, class: "align-items-center py-1" do
      (
        content_tag :div, class: "align-items-end" do
          content_tag :small, entry.created_at.strftime("%b %e, %Y"), class: "text-black-70 mr-2"
        end
      ) + #3
      (
        content_tag :div, class: "align-items-center py-1" do
          (content_tag(:small, entry.view_count.to_s + " view", class: "text-black-70 mr-2")) +
          (content_tag(:small, entry.collector_count.to_s + " collectors", class: "text-black-70")) #3
        end
      ) #3
      end
    ) #2
    end #1
  end

  def ect_3(entry)
    content_tag :div, class: "d-flex py-1" do
      (content_tag(:h6, "OWNER :", class: "text-muted mr-3")) +
      (content_tag(:h6, link_to(entry.profile.login, profile_path(entry.profile)), class: "text-black-70"))
    end
  end

  def entry_title(e)
    if !e.maker.blank? and !e.model.blank?
      "#{e.maker} #{e.model} #{e.heading}".entry_gsub
    elsif !e.maker.blank? and e.model.blank?
      "#{e.maker} #{e.heading}".entry_gsub
    elsif e.maker.blank? and !e.model.blank?
      "#{e.model} #{e.heading}".entry_gsub
    else
      "#{e.heading}"
    end
  end

  def twitter_cards(e)
    card_parms = {
      title: entry_title(e),
      description: "Post Your Gear! Guitars Archives Project Site",
      image: (
        if e.entry_images.first.present?
          polymorphic_url(
            e.entry_images.first.variant(resize_to_limit: [700, 700]),
            protocol: :https
          )
        else
          ""
        end
      )
    }
    card_parms
  end

  def profile_spec_tag(profile)
    specs = profile.attributes.delete_if { |key, value| value == "" || value.nil? }.
    slice(
      "play_field",
      "favorite_guitarist",
      "favorite_studybook",
      "favorite_band",
      "favorite_album",
      "favorite_video",
      "favorite_song",
      "play_history",
      "band",
      "blog",
      "website",
      "youtube",
      "twitter",
      "style"
      ).to_a
  # <tr>
  #  <td class="badge badge-secondary p-1 mt-1">play history</td>
  #  <td>30year</td>
  #</tr>
    specs.map do |s|
      content_tag :div, class: "p-1" do
        (
          content_tag(:div, I18n.t(s[0]), class: "badge badge-secondary p-1 mt-1")
        ) +
        (
          content_tag(:span, simple_format(profile.send(s[0].to_sym)), class: "text-black-70 ml-3")
        )
      end
    end
  end 
end

class String
  def entry_gsub
    self.tr("０-９ａ-ｚＡ-Ｚ", "0-9a-zA-Z")
        .gsub(/[()（）?？\/不明売却]/,
              "(" => " ", ")" => " ",
              "（" => " ", "）" => " ",
              "?" => "",
              "？" => "",
              "\/" => " ",
              "不明" => "",
              "売却" => "")
        .gsub(/\s-/, "")
        .split
        .uniq { |n| n.downcase }
        .join(" ")
  end
end
